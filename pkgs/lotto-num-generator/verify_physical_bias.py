#!/usr/bin/env python3
"""
前回検定で p < 0.05 が出た項目について「偶然ノイズ」か「再現性のある物理的癖」かを
前後半ホールドアウト・期間分割・構造分解で検証する専用スクリプト

使い方:
  python verify_physical_bias.py
"""

from __future__ import annotations

import io
import re
import time
import urllib.parse
import urllib.request
from html.parser import HTMLParser

import numpy as np
import pandas as pd
from scipy import stats


DATASETS_INDEX_URL = "https://loto-life.net/datasets"
USER_AGENT = "Mozilla/5.0 (compatible; LotteryPhysicalAudit/1.0)"
REQUEST_INTERVAL_SEC = 0.4

FALLBACK_SLUGS = {
    "numbers4": "numbers4",
    "bingo5": "bingo5",
    "miniloto": "mini-loto",
    "loto6": "loto6",
}

DATE_RE = re.compile(r"^\d{4}[-/年]\d{1,2}[-/月]\d{1,2}")
IGNORE_COL_KEYWORDS = (
    "日",
    "date",
    "ボーナス",
    "bonus",
    "賞金",
    "金額",
    "口数",
    "キャリー",
    "carry",
    "セット",
    "set",
    "ストレート",
    "ボックス",
    "ミニ",
    "販売",
    "1等",
    "2等",
    "3等",
    "4等",
    "5等",
    "6等",
    "7等",
    "曜日",
)


# =============================================================================
# 1. CSV自動ダウンロード・パース（単体実行用）
# =============================================================================


class LinkExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[tuple[str, str]] = []
        self._href: str | None = None
        self._buf: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag.lower() == "a":
            href = dict(attrs).get("href")
            if href:
                self._href = href
                self._buf = []

    def handle_data(self, data: str) -> None:
        if self._href is not None:
            self._buf.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "a" and self._href is not None:
            self.links.append((self._href, " ".join("".join(self._buf).split())))
            self._href = None
            self._buf = []


def fetch_text(url: str, timeout: int = 30) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read()
    for enc in ("cp932", "utf-8-sig", "utf-8", "shift_jis"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def extract_links(html: str, base_url: str) -> list[tuple[str, str]]:
    p = LinkExtractor()
    p.feed(html)
    return [(urllib.parse.urljoin(base_url, href), text) for href, text in p.links]


def discover_pages() -> dict[str, str]:
    pages: dict[str, str] = {}
    try:
        links = extract_links(fetch_text(DATASETS_INDEX_URL), DATASETS_INDEX_URL)
    except Exception:
        links = []
    hints_map = {
        "numbers4": ("/datasets/numbers4", "ナンバーズ4", "ナンバーズ４"),
        "bingo5": ("/datasets/bingo5", "ビンゴ5", "ビンゴ５"),
        "miniloto": ("/datasets/mini-loto", "/datasets/miniloto", "ミニロト"),
        "loto6": ("/datasets/loto6", "ロト6", "ロト６"),
    }
    for key, hints in hints_map.items():
        for href, text in links:
            if "/datasets/" in href and any(h in href or h in text for h in hints):
                pages[key] = href
                break
        if key not in pages:
            pages[key] = f"{DATASETS_INDEX_URL}/{FALLBACK_SLUGS[key]}"
    return pages


def download_df(page_url: str) -> pd.DataFrame:
    links = extract_links(fetch_text(page_url), page_url)
    csv_url = next((h for h, _ in links if ".csv" in h.lower()), None)
    if csv_url is None:
        csv_url = next(
            (
                h
                for h, t in links
                if ("csv" in h.lower() or "download" in h.lower())
                and "/datasets/" in h.lower()
            ),
            None,
        )
    if csv_url is None:
        raise RuntimeError(f"CSVリンクが見つかりません: {page_url}")
    time.sleep(REQUEST_INTERVAL_SEC)
    df = pd.read_csv(io.StringIO(fetch_text(csv_url)), dtype=str, keep_default_na=False)
    df.columns = [str(c).strip() for c in df.columns]
    return df


def sort_dedup(df: pd.DataFrame) -> tuple[pd.DataFrame, np.ndarray, str]:
    id_col = next(
        (
            c
            for c in df.columns
            if any(k in c.lower() for k in ("回", "draw", "round", "no"))
        ),
        df.columns[0],
    )
    work = df.copy()
    work["_id"] = pd.to_numeric(
        work[id_col].astype(str).str.extract(r"(\d+)")[0], errors="coerce"
    )
    work = work.dropna(subset=["_id"]).copy()
    work["_id"] = work["_id"].astype(int)
    work = (
        work.drop_duplicates(subset=["_id"], keep="last")
        .sort_values("_id")
        .reset_index(drop=True)
    )
    return work, work["_id"].to_numpy(dtype=int), id_col


def ignored_col(col: str, s: pd.Series) -> bool:
    if any(k in col.lower() for k in IGNORE_COL_KEYWORDS):
        return True
    return (
        s.head(20)
        .astype(str)
        .str.strip()
        .apply(lambda x: bool(DATE_RE.match(x)))
        .mean()
        > 0.5
    )


def parse_loto(
    df: pd.DataFrame, n_max: int, k: int, bingo: bool = False
) -> tuple[np.ndarray, np.ndarray]:
    work, ids, id_col = sort_dedup(df)
    cols = [
        c
        for c in work.columns
        if c not in ("_id", id_col) and not ignored_col(c, work[c])
    ]
    num_cols = []
    for c in cols:
        v = pd.to_numeric(work[c].astype(str).str.strip(), errors="coerce")
        if v.notna().all() and 1 <= int(v.min()) and int(v.max()) <= n_max:
            num_cols.append(c)
    if len(num_cols) >= k:
        mat = work[num_cols[:k]].apply(pd.to_numeric).to_numpy(dtype=int)
        if not bingo or all(
            np.all((mat[:, i] >= 5 * i + 1) & (mat[:, i] <= 5 * i + 5))
            for i in range(k)
        ):
            return mat, ids
    for c in cols:
        rows = [
            [int(x) for x in re.findall(r"\d+", val)][:k] for val in work[c].astype(str)
        ]
        if all(len(r) == k and all(1 <= x <= n_max for x in r) for r in rows):
            return np.asarray(rows, dtype=int), ids
    raise ValueError(f"列の特定に失敗: {list(df.columns)}")


def parse_numbers4(df: pd.DataFrame) -> tuple[np.ndarray, np.ndarray]:
    work, ids, id_col = sort_dedup(df)
    cols = [
        c
        for c in work.columns
        if c not in ("_id", id_col) and not ignored_col(c, work[c])
    ]
    cols.sort(
        key=lambda c: (
            0
            if any(k in c.lower() for k in ("当選", "当せん", "番号", "数字", "number"))
            else 1
        )
    )
    for c in cols:
        cl = work[c].astype(str).str.strip().str.replace(r"[\s-]", "", regex=True)
        if cl.str.fullmatch(r"\d+").all():
            nums = cl.astype(int)
            if (
                nums.min() >= 0
                and nums.max() <= 9999
                and not nums.is_monotonic_increasing
            ):
                strs = [f"{v:04d}" for v in nums.tolist()]
                return np.array([[int(ch) for ch in s] for s in strs], dtype=int), ids
    dcols = [
        c
        for c in cols
        if pd.to_numeric(work[c], errors="coerce").notna().all()
        and 0 <= int(pd.to_numeric(work[c]).min())
        and int(pd.to_numeric(work[c]).max()) <= 9
    ]
    if len(dcols) >= 4:
        return work[dcols[:4]].apply(pd.to_numeric).to_numpy(dtype=int), ids
    raise ValueError(f"N4列の特定に失敗: {list(df.columns)}")


def bh_fdr(p_values: np.ndarray) -> np.ndarray:
    p = np.asarray(p_values, dtype=float)
    m = len(p)
    order = np.argsort(p)
    q_ranked = np.minimum.accumulate((p[order] * m / np.arange(1, m + 1))[::-1])[::-1]
    q = np.empty(m, dtype=float)
    q[order] = np.clip(q_ranked, 0.0, 1.0)
    return q


# =============================================================================
# 2. ナンバーズ4 物理的癖の詳細検証
# =============================================================================


def verify_numbers4(digits: np.ndarray, ids: np.ndarray) -> None:
    T = len(digits)
    mid = T // 2
    d_first, d_second = digits[:mid], digits[mid:]

    print("=" * 90)
    print(
        f"[1] ナンバーズ4 物理的癖チェック (全{T}回: 第{ids[0]}回〜第{ids[-1]}回 / 分割点=第{ids[mid - 1]}回)"
    )
    print("=" * 90)

    # (A) 左から2桁目の前後半ホールドアウト再現性
    c_all = np.bincount(digits[:, 1], minlength=10)
    c1 = np.bincount(d_first[:, 1], minlength=10)
    c2 = np.bincount(d_second[:, 1], minlength=10)
    _, p_all = stats.chisquare(c_all)
    _, p1 = stats.chisquare(c1)
    _, p2 = stats.chisquare(c2)
    r_d2, p_r_d2 = stats.pearsonr(c1, c2)

    print("\n--- (A) 左から2桁目の出現回数: 前半 vs 後半 ---")
    print(
        f"全期間 χ² p={p_all:.4g} | 前半({len(d_first)}回) p={p1:.4g} | 後半({len(d_second)}回) p={p2:.4g}"
    )
    print(
        f"前後半の出現回数相関: r = {r_d2:+.3f} (p = {p_r_d2:.4g})  ※再現する癖があれば正の有意相関"
    )
    print("数字 |  全期間 (期待比) |   前半 |   後半 | 前後半で同方向か")
    e_all, e1, e2 = T / 10, len(d_first) / 10, len(d_second) / 10
    for d in range(10):
        same_dir = "同方向" if (c1[d] - e1) * (c2[d] - e2) > 0 else "逆転"
        print(
            f"  {d}  | {c_all[d]:4d} ({c_all[d] / e_all:5.1%}) | {c1[d]:4d}   | {c2[d]:4d}   | {same_dir}"
        )

    # 5期間分割での2桁目 χ²（特定時期だけの異常かチェック）
    print(
        "\n--- (A2) 左から2桁目の5期間分割チェック（抽選機交換・一時的異常の切り分け） ---"
    )
    chunks = np.array_split(np.arange(T), 5)
    for idx_c, ch in enumerate(chunks, 1):
        cc = np.bincount(digits[ch, 1], minlength=10)
        _, pc = stats.chisquare(cc)
        print(
            f"  第{idx_c}期 (第{ids[ch[0]]:4d}〜{ids[ch[-1]]:4d}回, n={len(ch)}): χ² p={pc:.4g} | 最多={cc.argmax()}({cc.max()}回), 最少={cc.argmin()}({cc.min()}回)"
        )

    # (B) 1桁目-2桁目 (10x10) の前後半残差相関（再現性チェック）
    def resid_matrix(arr: np.ndarray) -> np.ndarray:
        obs = np.zeros((10, 10), dtype=float)
        np.add.at(obs, (arr[:, 0], arr[:, 1]), 1)
        exp = np.outer(obs.sum(axis=1), obs.sum(axis=0)) / obs.sum()
        return (obs - exp) / np.sqrt(exp)

    z_all = resid_matrix(digits)
    z1 = resid_matrix(d_first)
    z2 = resid_matrix(d_second)
    r_pair, p_r_pair = stats.pearsonr(z1.ravel(), z2.ravel())

    # 独立帰無仮説下での順列検定（後半の2桁目をシャッフルしてz1との相関分布を作る）
    rng = np.random.default_rng(42)
    perm_rs = np.empty(2000)
    d2_col = d_second[:, 1].copy()
    for b in range(2000):
        rng.shuffle(d2_col)
        obs_b = np.zeros((10, 10), dtype=float)
        np.add.at(obs_b, (d_second[:, 0], d2_col), 1)
        exp_b = np.outer(obs_b.sum(axis=1), obs_b.sum(axis=0)) / obs_b.sum()
        zb = (obs_b - exp_b) / np.sqrt(exp_b)
        perm_rs[b] = np.corrcoef(z1.ravel(), zb.ravel())[0, 1]
    p_perm = float(np.mean(np.abs(perm_rs) >= abs(r_pair)))

    _, p_ct1, _, _ = stats.chi2_contingency(pd.crosstab(d_first[:, 0], d_first[:, 1]))
    _, p_ct2, _, _ = stats.chi2_contingency(pd.crosstab(d_second[:, 0], d_second[:, 1]))

    print("\n--- (B) 1桁目-2桁目 (10x10分割表) の再現性チェック ---")
    print(f"前半 10x10 χ² p={p_ct1:.4g} | 後半 10x10 χ² p={p_ct2:.4g}")
    print(
        f"前後半の残差相関 (100セル): r = {r_pair:+.3f} (通常p={p_r_pair:.4g}, 順列p={p_perm:.4g})"
    )
    print("全期間で残差絶対値が大きい上位6ペア (1桁目-2桁目):")
    flat_idx = np.argsort(np.abs(z_all.ravel()))[::-1][:6]
    for fi in flat_idx:
        a, b = divmod(int(fi), 10)
        cnt_all = int(np.sum((digits[:, 0] == a) & (digits[:, 1] == b)))
        cnt1 = int(np.sum((d_first[:, 0] == a) & (d_first[:, 1] == b)))
        cnt2 = int(np.sum((d_second[:, 0] == a) & (d_second[:, 1] == b)))
        print(
            f"  ({a},{b}): 全期間={cnt_all:3d}回 (Z={z_all[a, b]:+.2f}) | 前半Z={z1[a, b]:+.2f} ({cnt1}回) | 後半Z={z2[a, b]:+.2f} ({cnt2}回)"
        )

    # (C) 電動風車式特有のチェック: 前回からの進み幅 (d_t - d_{t-1}) mod 10 & 桁間差 (d2 - d1) mod 10
    print("\n--- (C) 風車盤の回転・連動の癖チェック (mod 10 差分一様性) ---")
    for col in range(4):
        step = (digits[1:, col] - digits[:-1, col]) % 10
        sc = np.bincount(step, minlength=10)
        _, ps = stats.chisquare(sc)
        print(
            f"  {col + 1}桁目の前回からの進み幅 (mod 10): χ² p={ps:.4g} | 最大=+{sc.argmax()}({sc.max()}回), 最小=+{sc.argmin()}({sc.min()}回)"
        )

    diff12 = (digits[:, 1] - digits[:, 0]) % 10
    dc12 = np.bincount(diff12, minlength=10)
    _, p_d12 = stats.chisquare(dc12)
    print(
        f"  1桁目と2桁目の同時差 (d2-d1 mod 10): χ² p={p_d12:.4g} | 最大=+{dc12.argmax()}({dc12.max()}回), 最小=+{dc12.argmin()}({dc12.min()}回)"
    )


# =============================================================================
# 3. ビンゴ5 前回同位置連続出現の詳細検証
# =============================================================================


def verify_bingo5(draws: np.ndarray, ids: np.ndarray) -> None:
    T = len(draws)
    offsets = draws - (np.arange(8) * 5)
    same = offsets[1:] == offsets[:-1]  # shape (T-1, 8)
    mid = (T - 1) // 2

    print("\n" + "=" * 90)
    print(
        f"[2] ビンゴ5 前回同位置連続出現チェック (全{T}回: 第{ids[0]}回〜第{ids[-1]}回)"
    )
    print("=" * 90)

    # (A) 前後半ホールドアウト
    s1, n1 = int(same[:mid].sum()), mid * 8
    s2, n2 = int(same[mid:].sum()), (T - 1 - mid) * 8
    p1 = stats.binomtest(s1, n=n1, p=0.2).pvalue
    p2 = stats.binomtest(s2, n=n2, p=0.2).pvalue
    print("\n--- (A) 前半 vs 後半の連続一致率 (理論=20.00%) ---")
    print(f"  前半 (第{ids[1]}〜{ids[mid]}回): {s1}/{n1} = {s1 / n1:.2%} (p={p1:.4g})")
    print(
        f"  後半 (第{ids[mid + 1]}〜{ids[-1]}回): {s2}/{n2} = {s2 / n2:.2%} (p={p2:.4g})"
    )

    # (B) 全8枠別の内訳
    print("\n--- (B) 枠別（第1〜第8枠）の連続一致率 ---")
    slot_counts = same.sum(axis=0)
    slot_ps = np.array(
        [stats.binomtest(int(c), n=T - 1, p=0.2).pvalue for c in slot_counts]
    )
    slot_qs = bh_fdr(slot_ps)
    for i in range(8):
        c1_i = int(same[:mid, i].sum())
        c2_i = int(same[mid:, i].sum())
        print(
            f"  第{i + 1}枠 ({5 * i + 1:2d}〜{5 * i + 5:2d}): {slot_counts[i]:3d}/{T - 1} ({slot_counts[i] / (T - 1):6.2%}) "
            f"| raw_p={slot_ps[i]:.4g}, FDR_q={slot_qs[i]:.4g} | 前半={c1_i / mid:5.1%}, 後半={c2_i / (T - 1 - mid):5.1%}"
        )

    # (C) ラグ別一致率 (ラグ1〜5)
    print("\n--- (C) ラグ別（1〜5回前との）同位置一致率 ---")
    for lag in range(1, 6):
        m = offsets[lag:] == offsets[:-lag]
        cnt, tot = int(m.sum()), m.size
        pl = stats.binomtest(cnt, n=tot, p=0.2).pvalue
        print(f"  ラグ{lag}: {cnt:4d}/{tot} ({cnt / tot:.2%}) p={pl:.4g}")


# =============================================================================
# 4. ミニロト・ロト6 の前後半再現性チェック（参考確認）
# =============================================================================


def verify_miniloto_and_loto6(
    mini: np.ndarray, mini_ids: np.ndarray, loto6: np.ndarray, loto6_ids: np.ndarray
) -> None:
    print("\n" + "=" * 90)
    print("[3] 参考チェック: ミニロト出現頻度 & ロト6前回引っ張り個数の前後半再現性")
    print("=" * 90)

    # ミニロト
    Tm = len(mini)
    mm = Tm // 2
    mc1 = np.bincount(mini[:mm].ravel(), minlength=32)[1:]
    mc2 = np.bincount(mini[mm:].ravel(), minlength=32)[1:]
    _, mp1 = stats.chisquare(mc1)
    _, mp2 = stats.chisquare(mc2)
    fpc_m = (31 - 1) / (31 - 5)
    q1 = fpc_m * np.sum((mc1 - mm * 5 / 31) ** 2 / (mm * 5 / 31))
    q2 = fpc_m * np.sum((mc2 - (Tm - mm) * 5 / 31) ** 2 / ((Tm - mm) * 5 / 31))
    rm, prm = stats.pearsonr(mc1, mc2)
    print(f"\n--- ミニロト (全{Tm}回: 第{mini_ids[0]}〜{mini_ids[-1]}回) ---")
    print(
        f"  前半非復元χ² p={stats.chi2.sf(q1, 30):.4g} (合計平均={mini[:mm].sum(axis=1).mean():.2f})"
    )
    print(
        f"  後半非復元χ² p={stats.chi2.sf(q2, 30):.4g} (合計平均={mini[mm:].sum(axis=1).mean():.2f})"
    )
    print(f"  前後半31数字の出現回数相関: r = {rm:+.3f} (p = {prm:.4g})")

    # ロト6 前回引っ張り個数の分布内訳
    T6 = len(loto6)
    ov = np.array([len(set(loto6[t]).intersection(loto6[t - 1])) for t in range(1, T6)])
    m6 = len(ov) // 2
    pmf = stats.hypergeom.pmf(np.arange(7), M=43, n=6, N=6)
    print(
        f"\n--- ロト6 前回引っ張り個数分布 (全{T6}回: 第{loto6_ids[0]}〜{loto6_ids[-1]}回) ---"
    )
    print("  一致個数 |  理論率 |  全期間実測 |  前半実測 |  後半実測")
    for k_ov in range(5):
        if k_ov < 4:
            r_all = np.mean(ov == k_ov)
            r_1 = np.mean(ov[:m6] == k_ov)
            r_2 = np.mean(ov[m6:] == k_ov)
            th = pmf[k_ov]
            label = f"   {k_ov}個  "
        else:
            r_all = np.mean(ov >= 4)
            r_1 = np.mean(ov[:m6] >= 4)
            r_2 = np.mean(ov[m6:] >= 4)
            th = pmf[4:].sum()
            label = "  4個以上"
        print(f"  {label} | {th:6.2%} |   {r_all:6.2%}   |  {r_1:6.2%}  |  {r_2:6.2%}")


# =============================================================================
# 5. メイン実行
# =============================================================================


def main() -> None:
    print("データセット取得中...")
    pages = discover_pages()

    n4_digits, n4_ids = parse_numbers4(download_df(pages["numbers4"]))
    b5_draws, b5_ids = parse_loto(download_df(pages["bingo5"]), 40, 8, bingo=True)
    m_draws, m_ids = parse_loto(download_df(pages["miniloto"]), 31, 5)
    l6_draws, l6_ids = parse_loto(download_df(pages["loto6"]), 43, 6)

    verify_numbers4(n4_digits, n4_ids)
    verify_bingo5(b5_draws, b5_ids)
    verify_miniloto_and_loto6(m_draws, m_ids, l6_draws, l6_ids)


if __name__ == "__main__":
    main()
