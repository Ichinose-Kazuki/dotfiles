#!/usr/bin/env python3
"""
日本版数字選択式宝くじ（ロト6, ロト7, ミニロト, ビンゴ5, ナンバーズ4, ナンバーズ3）
過去全当選番号CSV 自動ダウンロード + 統計的偏り・独立性・フィルター中立性 包括検定スクリプト

使い方:
  python audit_lottery_bias.py
  python audit_lottery_bias.py --only loto6 loto7
  python audit_lottery_bias.py --save-dir ./downloaded_csvs
"""

from __future__ import annotations

import argparse
import io
import random
import re
import time
import urllib.parse
import urllib.request
from dataclasses import dataclass
from html.parser import HTMLParser
from itertools import combinations
from pathlib import Path
from typing import Callable

import numpy as np
import pandas as pd
from scipy import stats


DATASETS_INDEX_URL = "https://loto-life.net/datasets"
USER_AGENT = "Mozilla/5.0 (compatible; LotteryBiasAudit/1.0)"
REQUEST_INTERVAL_SEC = 0.5

# 一覧ページからの自動解決に失敗した場合のフォールバック用スラッグ
FALLBACK_SLUGS = {
    "loto6": "loto6",
    "loto7": "loto7",
    "miniloto": "mini-loto",
    "bingo5": "bingo5",
    "numbers4": "numbers4",
    "numbers3": "numbers3",
}

LOTTERY_LABELS = {
    "loto6": "ロト6",
    "loto7": "ロト7",
    "miniloto": "ミニロト",
    "bingo5": "ビンゴ5",
    "numbers4": "ナンバーズ4",
    "numbers3": "ナンバーズ3",
}


# =============================================================================
# 1. HTMLリンク抽出・CSV自動ダウンロード
# =============================================================================


class LinkExtractor(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[tuple[str, str]] = []
        self._href: str | None = None
        self._buf: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag.lower() == "a":
            attr_map = dict(attrs)
            if attr_map.get("href"):
                self._href = attr_map["href"]
                self._buf = []

    def handle_data(self, data: str) -> None:
        if self._href is not None:
            self._buf.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.lower() == "a" and self._href is not None:
            text = " ".join("".join(self._buf).split())
            self.links.append((self._href, text))
            self._href = None
            self._buf = []


def fetch_bytes(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


def decode_text(raw: bytes) -> str:
    for enc in ("cp932", "utf-8-sig", "utf-8", "shift_jis"):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            continue
    return raw.decode("utf-8", errors="replace")


def extract_links(html: str, base_url: str) -> list[tuple[str, str]]:
    parser = LinkExtractor()
    parser.feed(html)
    return [(urllib.parse.urljoin(base_url, href), text) for href, text in parser.links]


def discover_dataset_pages(index_url: str = DATASETS_INDEX_URL) -> dict[str, str]:
    """一覧ページから各宝くじのデータセットページURLを解決"""
    pages: dict[str, str] = {}
    try:
        html = decode_text(fetch_bytes(index_url))
        links = extract_links(html, index_url)
    except Exception:
        links = []

    slug_patterns = {
        "loto6": ("/datasets/loto6", "ロト6", "ロト６"),
        "loto7": ("/datasets/loto7", "ロト7", "ロト７"),
        "miniloto": ("/datasets/mini-loto", "/datasets/miniloto", "ミニロト"),
        "bingo5": ("/datasets/bingo5", "ビンゴ5", "ビンゴ５"),
        "numbers4": ("/datasets/numbers4", "ナンバーズ4", "ナンバーズ４"),
        "numbers3": ("/datasets/numbers3", "ナンバーズ3", "ナンバーズ３"),
    }

    for key, hints in slug_patterns.items():
        for href, text in links:
            if "/datasets/" not in href:
                continue
            if any(h in href or h in text for h in hints):
                pages[key] = href
                break
        if key not in pages:
            pages[key] = f"{index_url.rstrip('/')}/{FALLBACK_SLUGS[key]}"

    return pages


def find_csv_url(page_url: str) -> str:
    """データセットページ内のCSVダウンロードURLを自動検出"""
    html = decode_text(fetch_bytes(page_url))
    links = extract_links(html, page_url)

    # 優先1: hrefに .csv を含むリンク
    for href, _ in links:
        if ".csv" in href.lower():
            return href
    # 優先2: hrefまたはテキストに csv / download を含むリンク
    for href, text in links:
        h_low, t_low = href.lower(), text.lower()
        if ("csv" in h_low or "download" in h_low) and "/datasets/" in h_low:
            return href
        if "csv" in t_low and ("ダウンロード" in text or "download" in t_low):
            return href

    raise RuntimeError(f"CSVダウンロードリンクが見つかりませんでした: {page_url}")


def download_csv_dataframe(
    key: str,
    page_url: str,
    save_dir: Path | None = None,
) -> pd.DataFrame:
    """CSVを自動取得してすべて文字列カラムのDataFrameとして返す"""
    csv_url = find_csv_url(page_url)
    time.sleep(REQUEST_INTERVAL_SEC)
    raw = fetch_bytes(csv_url)

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        (save_dir / f"{key}.csv").write_bytes(raw)

    text = decode_text(raw)
    # 空行やコメント行を飛ばしてCSV読み込み
    df = pd.read_csv(io.StringIO(text), dtype=str, keep_default_na=False)
    df.columns = [str(c).strip() for c in df.columns]
    return df


# =============================================================================
# 2. 堅牢なCSVパーサー（列名の差異を吸収）
# =============================================================================

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


def extract_draw_ids(df: pd.DataFrame) -> pd.Series:
    """回号列を特定して整数Seriesを返す"""
    id_col = None
    for col in df.columns:
        c_low = col.lower()
        if any(k in c_low for k in ("回", "draw", "round", "no")):
            id_col = col
            break
    if id_col is None:
        id_col = df.columns[0]

    ids = df[id_col].astype(str).str.extract(r"(\d+)")[0]
    return pd.to_numeric(ids, errors="coerce")


def sort_and_dedup(df: pd.DataFrame) -> tuple[pd.DataFrame, np.ndarray]:
    work = df.copy()
    work["_draw_id"] = extract_draw_ids(work)
    work = work.dropna(subset=["_draw_id"]).copy()
    work["_draw_id"] = work["_draw_id"].astype(int)
    work = work.drop_duplicates(subset=["_draw_id"], keep="last")
    work = work.sort_values("_draw_id").reset_index(drop=True)
    return work, work["_draw_id"].to_numpy(dtype=int)


def is_ignored_col(col_name: str, series: pd.Series) -> bool:
    c_low = col_name.lower()
    if any(k in c_low for k in IGNORE_COL_KEYWORDS):
        return True
    sample = series.head(20).astype(str).str.strip()
    if sample.apply(lambda s: bool(DATE_RE.match(s))).mean() > 0.5:
        return True
    return False


def parse_loto_df(
    df: pd.DataFrame,
    n_max: int,
    k: int,
    bingo_mode: bool = False,
) -> tuple[np.ndarray, np.ndarray]:
    """ロト6 / ロト7 / ミニロト / ビンゴ5 の当選数字配列 (T, k) を抽出"""
    work, draw_ids = sort_and_dedup(df)
    data_cols = [c for c in work.columns if c != "_draw_id"]

    # 回号列と思われる先頭列を除外候補にする
    id_col_name = None
    for c in data_cols:
        if any(tok in c.lower() for tok in ("回", "draw", "round", "no")):
            id_col_name = c
            break
    if id_col_name is None:
        id_col_name = data_cols[0]

    # 方法A: 個別の数値列が k 列以上ある形式
    valid_num_cols: list[str] = []
    for c in data_cols:
        if c == id_col_name or is_ignored_col(c, work[c]):
            continue
        nums = pd.to_numeric(work[c].astype(str).str.strip(), errors="coerce")
        if nums.notna().all():
            vmin, vmax = int(nums.min()), int(nums.max())
            if 1 <= vmin and vmax <= n_max:
                valid_num_cols.append(c)

    if len(valid_num_cols) >= k:
        cand = work[valid_num_cols[:k]].apply(pd.to_numeric).to_numpy(dtype=int)
        if _validate_loto_matrix(cand, n_max, k, bingo_mode):
            return cand, draw_ids

    # 方法B: 1列にスペース/カンマ区切り等で k 個の数字が入っている形式
    for c in data_cols:
        if c == id_col_name or is_ignored_col(c, work[c]):
            continue
        parsed_rows: list[list[int]] = []
        ok = True
        for val in work[c].astype(str):
            toks = [int(x) for x in re.findall(r"\d+", val)]
            if len(toks) < k:
                ok = False
                break
            row_nums = toks[:k]
            if any(x < 1 or x > n_max for x in row_nums):
                ok = False
                break
            parsed_rows.append(row_nums)
        if ok and parsed_rows:
            cand = np.asarray(parsed_rows, dtype=int)
            if _validate_loto_matrix(cand, n_max, k, bingo_mode):
                return cand, draw_ids

    raise ValueError(
        f"当選数字列を特定できませんでした (columns={list(df.columns)}, sample={df.head(2).to_dict('records')})"
    )


def _validate_loto_matrix(
    mat: np.ndarray, n_max: int, k: int, bingo_mode: bool
) -> bool:
    if mat.ndim != 2 or mat.shape[1] != k or mat.shape[0] == 0:
        return False
    if np.any(mat < 1) or np.any(mat > n_max):
        return False
    if bingo_mode:
        for i in range(k):
            lo, hi = 5 * i + 1, 5 * i + 5
            if np.any((mat[:, i] < lo) | (mat[:, i] > hi)):
                return False
        return True
    # ロト系: 各行の数字に重複がないこと
    return all(len(set(row)) == k for row in mat)


def parse_numbers_df(df: pd.DataFrame, width: int) -> tuple[list[str], np.ndarray]:
    """ナンバーズ3 / ナンバーズ4 のゼロ埋め文字列リストを抽出"""
    work, draw_ids = sort_and_dedup(df)
    data_cols = [c for c in work.columns if c != "_draw_id"]

    id_col_name = None
    for c in data_cols:
        if any(tok in c.lower() for tok in ("回", "draw", "round", "no")):
            id_col_name = c
            break
    if id_col_name is None:
        id_col_name = data_cols[0]

    # 方法A: 1列に3桁/4桁の数字が入っている形式（ヘッダ名で優先順位付け）
    candidates = [
        c for c in data_cols if c != id_col_name and not is_ignored_col(c, work[c])
    ]
    candidates.sort(
        key=lambda c: (
            0
            if any(k in c.lower() for k in ("当選", "当せん", "番号", "数字", "number"))
            else 1
        )
    )

    max_val = (10**width) - 1
    for c in candidates:
        cleaned = work[c].astype(str).str.strip().str.replace(r"[\s-]", "", regex=True)
        if cleaned.str.fullmatch(r"\d+").all():
            nums = cleaned.astype(int)
            if nums.min() >= 0 and nums.max() <= max_val:
                # 回号列と誤認していないか（単調増加でないか）を確認
                if not nums.is_monotonic_increasing:
                    return [f"{v:0{width}d}" for v in nums.tolist()], draw_ids

    # 方法B: 桁ごとに列が分かれている形式（各列 0..9）
    digit_cols: list[str] = []
    for c in candidates:
        nums = pd.to_numeric(work[c].astype(str).str.strip(), errors="coerce")
        if nums.notna().all() and int(nums.min()) >= 0 and int(nums.max()) <= 9:
            digit_cols.append(c)
    if len(digit_cols) >= width:
        mat = work[digit_cols[:width]].apply(pd.to_numeric).to_numpy(dtype=int)
        return ["".join(str(x) for x in row) for row in mat], draw_ids

    raise ValueError(
        f"ナンバーズ{width}の当選番号列を特定できませんでした (columns={list(df.columns)})"
    )


# =============================================================================
# 3. 共通統計ユーティリティ & 不人気フィルター定義
# =============================================================================


@dataclass
class TestResult:
    lottery: str
    test_name: str
    statistic: float
    p_value: float
    detail: str


def bh_fdr(p_values: np.ndarray) -> np.ndarray:
    """Benjamini-Hochberg法によるFDR補正（q値の算出）"""
    p = np.asarray(p_values, dtype=float)
    m = len(p)
    if m == 0:
        return np.array([], dtype=float)
    order = np.argsort(p)
    ranked = p[order]
    q_ranked = ranked * m / np.arange(1, m + 1)
    q_ranked = np.minimum.accumulate(q_ranked[::-1])[::-1]
    q_ranked = np.clip(q_ranked, 0.0, 1.0)
    q = np.empty(m, dtype=float)
    q[order] = q_ranked
    return q


def pick_most_extreme(
    p_values: np.ndarray,
    tie_scores: np.ndarray | None = None,
) -> tuple[int, int]:
    """
    NaNを除外して最小raw_pのインデックスと、同率最小の件数を返す。
    p値が同率（アンダーフロー含む）の場合は tie_scores が最大の要素を優先する。
    """
    p = np.asarray(p_values, dtype=float)
    valid = np.where(~np.isnan(p))[0]
    if len(valid) == 0:
        return 0, 0
    min_p = np.min(p[valid])
    tied = valid[np.isclose(p[valid], min_p, rtol=1e-12, atol=1e-300)]
    if len(tied) == 1 or tie_scores is None:
        return int(tied[0]), int(len(tied))
    scores = np.asarray(tie_scores, dtype=float)
    best = tied[int(np.argmax(scores[tied]))]
    return int(best), int(len(tied))


def pass_loto6_filter(nums: list[int]) -> bool:
    s = sorted(nums)
    diffs = [s[i + 1] - s[i] for i in range(5)]
    if sum(1 for x in s if x <= 12) >= 2:
        return False
    if sum(1 for x in s if x >= 32) <= 1:
        return False
    if min(diffs) >= 4:
        return False
    if any(diffs[i] == 1 and diffs[i + 1] == 1 for i in range(4)):
        return False
    if len(set(diffs)) <= 2:
        return False
    if max(sum(1 for x in s if x % 5 == r) for r in range(5)) >= 4:
        return False
    if max(sum(1 for x in s if x % 7 == r) for r in range(7)) >= 4:
        return False
    return True


def pass_loto7_filter(nums: list[int]) -> bool:
    s = sorted(nums)
    diffs = [s[i + 1] - s[i] for i in range(6)]
    if sum(1 for x in s if x <= 12) >= 2:
        return False
    if sum(1 for x in s if x >= 32) <= 1:
        return False
    if min(diffs) >= 3:
        return False
    if any(diffs[i] == 1 and diffs[i + 1] == 1 and diffs[i + 2] == 1 for i in range(4)):
        return False
    if len(set(diffs)) <= 2:
        return False
    if max(sum(1 for x in s if x % 5 == r) for r in range(5)) >= 4:
        return False
    if max(sum(1 for x in s if x % 7 == r) for r in range(7)) >= 4:
        return False
    return True


def pass_miniloto_filter(nums: list[int]) -> bool:
    s = sorted(nums)
    diffs = [s[i + 1] - s[i] for i in range(4)]
    if sum(1 for x in s if x <= 12) >= 2:
        return False
    if not any(x >= 29 for x in s):
        return False
    if min(diffs) >= 4:
        return False
    if len(set(diffs)) == 1:
        return False
    if max(sum(1 for x in s if x % 5 == r) for r in range(5)) >= 3:
        return False
    return True


def pass_bingo5_filter(nums: list[int]) -> bool:
    offsets = [nums[i] - 5 * i for i in range(8)]
    if max(offsets.count(o) for o in range(1, 6)) >= 4:
        return False
    if sum(1 for i in range(4) if offsets[i] == offsets[7 - i]) >= 3:
        return False
    if sum(1 for i in range(4) if offsets[i] + offsets[7 - i] == 6) >= 3:
        return False
    if nums[1] in (7, 8) and offsets.count(3) >= 3:
        return False
    if not any(nums[i + 1] - nums[i] == 1 for i in range(7)):
        return False
    return True


def pass_numbers4_filter(s: str) -> bool:
    n = int(s)
    d = [int(c) for c in s]
    u, l = n // 100, n % 100
    if 1900 <= n <= 2035:
        return False
    if (1 <= u <= 12 and 1 <= l <= 31) or (u == 0 and 1 <= l <= 31):
        return False
    if len(set(d)) <= 2:
        return False
    if len({d[i + 1] - d[i] for i in range(3)}) == 1:
        return False
    if s == s[::-1] or l == 0:
        return False
    if set(d).issubset({3, 5, 8}) or sum(1 for x in d if x in {7, 8}) >= 3:
        return False
    return True


def pass_numbers3_filter(s: str) -> bool:
    n = int(s)
    d = [int(c) for c in s]
    u, l = n // 100, n % 100
    if (1 <= u <= 9 and 1 <= l <= 31) or (u == 0 and 1 <= l <= 12):
        return False
    if len(set(d)) == 1 or d[0] == d[2]:
        return False
    if d[1] - d[0] == d[2] - d[1]:
        return False
    if d[2] == 0:
        return False
    if sum(1 for x in d if x in {3, 5, 8}) >= 2 or set(d) == {1, 6, 8}:
        return False
    return True


def estimate_loto_filter_rate(
    n_max: int,
    k: int,
    predicate: Callable[[list[int]], bool],
    n_mc: int,
    seed: int = 42,
) -> float:
    rng = random.Random(seed)
    pool = range(1, n_max + 1)
    passed = sum(1 for _ in range(n_mc) if predicate(rng.sample(pool, k)))
    return passed / n_mc


def estimate_bingo5_filter_rate(n_mc: int, seed: int = 42) -> float:
    rng = random.Random(seed)
    passed = 0
    for _ in range(n_mc):
        row = [5 * i + rng.randint(1, 5) for i in range(8)]
        if pass_bingo5_filter(row):
            passed += 1
    return passed / n_mc


def exact_numbers_filter_rate(n_digits: int, predicate: Callable[[str], bool]) -> float:
    """ナンバーズ3(1,000通り)・4(10,000通り)は全数探索で理論通過率の厳密値を算出"""
    total = 10**n_digits
    fmt = f"{{:0{n_digits}d}}"
    passed = sum(1 for n in range(total) if predicate(fmt.format(n)))
    return passed / total


# =============================================================================
# 4. 統計検定エンジン（ロト系 / ビンゴ5 / ナンバーズ）
# =============================================================================


def audit_loto(
    name: str,
    draws: np.ndarray,
    n_max: int,
    k: int,
    filter_fn: Callable[[list[int]], bool],
    mc_samples: int,
) -> list[TestResult]:
    T = draws.shape[0]
    results: list[TestResult] = []

    # (1) 非復元抽出補正付きカイ二乗適合度検定
    counts = np.bincount(draws.ravel(), minlength=n_max + 1)[1:]
    expected = T * k / n_max
    raw_chi2 = np.sum((counts - expected) ** 2 / expected)
    fpc = (n_max - 1) / (n_max - k)
    q_stat = fpc * raw_chi2
    p_uniform = float(stats.chi2.sf(q_stat, df=n_max - 1))
    results.append(
        TestResult(
            name,
            "1. 出現頻度の一様性 (非復元補正χ²)",
            q_stat,
            p_uniform,
            f"T={T}, min={counts.min()}(#{counts.argmin() + 1}), max={counts.max()}(#{counts.argmax() + 1}), E={expected:.1f}",
        )
    )

    # (2) 個別数字の二項検定 + BH-FDR
    p_single = np.array(
        [stats.binomtest(int(c), n=T, p=k / n_max).pvalue for c in counts]
    )
    q_single = bh_fdr(p_single)
    min_idx, n_tied = pick_most_extreme(p_single, tie_scores=np.abs(counts - expected))
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    results.append(
        TestResult(
            name,
            "2. 個別数字の突出 (二項検定+FDR)",
            float(counts[min_idx]),
            float(q_single[min_idx]),
            f"最極端=#{min_idx + 1} ({counts[min_idx]}回, raw_p={p_single[min_idx]:.4g}, FDR_q={q_single[min_idx]:.4g}){tie_note}",
        )
    )

    # (3) ペア共起の偏り検定 + BH-FDR
    pair_counts = np.zeros((n_max + 1, n_max + 1), dtype=int)
    for row in draws:
        for a, b in combinations(sorted(row), 2):
            pair_counts[a, b] += 1
    p_pair_prob = (k * (k - 1)) / (n_max * (n_max - 1))
    pair_list = [
        (a, b, pair_counts[a, b])
        for a in range(1, n_max)
        for b in range(a + 1, n_max + 1)
    ]
    p_pairs = np.array(
        [stats.binomtest(c, n=T, p=p_pair_prob).pvalue for _, _, c in pair_list]
    )
    q_pairs = bh_fdr(p_pairs)
    pair_dev = np.array([abs(c - T * p_pair_prob) for _, _, c in pair_list])
    best_p_idx, n_tied = pick_most_extreme(p_pairs, tie_scores=pair_dev)
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    pa, pb, pc = pair_list[best_p_idx]
    results.append(
        TestResult(
            name,
            "3. ペア共起の偏り (二項検定+FDR)",
            float(pc),
            float(q_pairs[best_p_idx]),
            f"最極端=({pa},{pb}) 共起{pc}回 (E={T * p_pair_prob:.1f}, raw_p={p_pairs[best_p_idx]:.4g}, FDR_q={q_pairs[best_p_idx]:.4g}){tie_note}",
        )
    )

    # (4) 時系列独立性: 前回引っ張り個数 vs 超幾何分布
    overlaps = np.array(
        [len(set(draws[t]).intersection(draws[t - 1])) for t in range(1, T)]
    )
    obs_ov = np.bincount(overlaps, minlength=k + 1)
    exp_ov = (T - 1) * stats.hypergeom.pmf(np.arange(k + 1), M=n_max, n=k, N=k)
    obs_merged, exp_merged = [], []
    o_acc, e_acc = 0.0, 0.0
    for o, e in zip(obs_ov, exp_ov):
        o_acc += o
        e_acc += e
        if e_acc >= 5.0:
            obs_merged.append(o_acc)
            exp_merged.append(e_acc)
            o_acc, e_acc = 0.0, 0.0
    if e_acc > 0:
        if obs_merged:
            obs_merged[-1] += o_acc
            exp_merged[-1] += e_acc
        else:
            obs_merged.append(o_acc)
            exp_merged.append(e_acc)
    obs_arr = np.asarray(obs_merged, dtype=float)
    exp_arr = np.asarray(exp_merged, dtype=float)
    exp_arr *= obs_arr.sum() / exp_arr.sum()
    chi2_ov, p_ov = stats.chisquare(obs_arr, f_exp=exp_arr)
    results.append(
        TestResult(
            name,
            "4. 前回引っ張り個数 (超幾何適合度)",
            float(chi2_ov),
            float(p_ov),
            f"平均一致={overlaps.mean():.3f} (理論={k * k / n_max:.3f})",
        )
    )

    # (5) 当選数字合計の平均検定（1標本t検定）
    row_sums = draws.sum(axis=1)
    theo_mean = k * (n_max + 1) / 2.0
    t_stat, p_sum = stats.ttest_1samp(row_sums, popmean=theo_mean)
    results.append(
        TestResult(
            name,
            "5. 当選数字合計の平均検定 (1標本t)",
            float(t_stat),
            float(p_sum),
            f"実測平均={row_sums.mean():.2f} (理論={theo_mean:.2f})",
        )
    )

    # (6) 不人気フィルター通過率の実測 vs 理論値
    obs_pass = sum(1 for row in draws if filter_fn(row.tolist()))
    theo_rate = estimate_loto_filter_rate(n_max, k, filter_fn, n_mc=mc_samples)
    p_filt = stats.binomtest(obs_pass, n=T, p=theo_rate).pvalue
    results.append(
        TestResult(
            name,
            "6. 不人気フィルター通過率 (二項検定)",
            obs_pass / T,
            float(p_filt),
            f"実測={obs_pass}/{T} ({obs_pass / T:.2%}) vs 理論={theo_rate:.2%}",
        )
    )

    return results


def audit_bingo5(draws: np.ndarray, mc_samples: int) -> list[TestResult]:
    name = "ビンゴ5"
    T = draws.shape[0]
    offsets = draws - (np.arange(8) * 5)
    results: list[TestResult] = []

    # (1) 各枠の一様性 + BH-FDR
    p_slots, chi2_slots = [], []
    for i in range(8):
        c = np.bincount(offsets[:, i], minlength=6)[1:]
        stat, p = stats.chisquare(c)
        chi2_slots.append(float(stat))
        p_slots.append(float(p))
    q_slots = bh_fdr(np.array(p_slots))
    worst, n_tied = pick_most_extreme(
        np.array(p_slots), tie_scores=np.array(chi2_slots)
    )
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    results.append(
        TestResult(
            name,
            "1. 各枠内の一様性 (8枠χ²+FDR)",
            chi2_slots[worst],
            float(q_slots[worst]),
            f"最極端=第{worst + 1}枠 (raw_p={p_slots[worst]:.4g}, FDR_q={q_slots[worst]:.4g}){tie_note}",
        )
    )

    # (2) 枠間独立性（28ペア 5x5分割表χ² + BH-FDR）
    p_indep, pairs = [], []
    for i, j in combinations(range(8), 2):
        ct = pd.crosstab(offsets[:, i], offsets[:, j])
        chi2_val, p_val, _, _ = stats.chi2_contingency(ct)
        p_indep.append(float(p_val))
        pairs.append((i + 1, j + 1, float(chi2_val)))
    q_indep = bh_fdr(np.array(p_indep))
    w_idx, n_tied = pick_most_extreme(
        np.array(p_indep), tie_scores=np.array([x[2] for x in pairs])
    )
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    results.append(
        TestResult(
            name,
            "2. 枠間の独立性 (28ペア5x5χ²+FDR)",
            pairs[w_idx][2],
            float(q_indep[w_idx]),
            f"最極端=枠{pairs[w_idx][0]}-枠{pairs[w_idx][1]} (raw_p={p_indep[w_idx]:.4g}, FDR_q={q_indep[w_idx]:.4g}){tie_note}",
        )
    )

    # (3) 前回同位置の連続出現率
    same_count = int(np.sum(offsets[1:] == offsets[:-1]))
    total_cells = (T - 1) * 8
    p_lag = stats.binomtest(same_count, n=total_cells, p=0.2).pvalue
    results.append(
        TestResult(
            name,
            "3. 前回同位置の連続出現 (二項検定)",
            same_count / total_cells,
            float(p_lag),
            f"一致={same_count}/{total_cells} ({same_count / total_cells:.2%} vs 理論20.00%)",
        )
    )

    # (4) フィルター通過率検証
    obs_pass = sum(1 for row in draws if pass_bingo5_filter(row.tolist()))
    theo_rate = estimate_bingo5_filter_rate(n_mc=mc_samples)
    p_filt = stats.binomtest(obs_pass, n=T, p=theo_rate).pvalue
    results.append(
        TestResult(
            name,
            "4. 不人気フィルター通過率 (二項検定)",
            obs_pass / T,
            float(p_filt),
            f"実測={obs_pass}/{T} ({obs_pass / T:.2%}) vs 理論={theo_rate:.2%}",
        )
    )

    return results


def audit_numbers(
    name: str,
    strings: list[str],
    n_digits: int,
    filter_fn: Callable[[str], bool],
) -> list[TestResult]:
    T = len(strings)
    digits = np.array([[int(c) for c in s] for s in strings], dtype=int)
    vals = np.array([int(s) for s in strings], dtype=int)
    results: list[TestResult] = []

    # (1) 各桁の一様性 + BH-FDR
    p_cols, chi2_cols = [], []
    for col in range(n_digits):
        c = np.bincount(digits[:, col], minlength=10)
        stat, p = stats.chisquare(c)
        chi2_cols.append(float(stat))
        p_cols.append(float(p))
    q_cols = bh_fdr(np.array(p_cols))
    worst, n_tied = pick_most_extreme(np.array(p_cols), tie_scores=np.array(chi2_cols))
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    results.append(
        TestResult(
            name,
            "1. 各桁の一様性 (0-9 χ²+FDR)",
            chi2_cols[worst],
            float(q_cols[worst]),
            f"最極端=左から{worst + 1}桁目 (raw_p={p_cols[worst]:.4g}, FDR_q={q_cols[worst]:.4g}){tie_note}",
        )
    )

    # (2) 桁間の独立性（10x10分割表χ² + BH-FDR）
    p_indep, pair_info = [], []
    for i, j in combinations(range(n_digits), 2):
        ct = pd.crosstab(digits[:, i], digits[:, j])
        chi2_val, p_val, _, _ = stats.chi2_contingency(ct)
        p_indep.append(float(p_val))
        pair_info.append((i + 1, j + 1, float(chi2_val)))
    q_indep = bh_fdr(np.array(p_indep))
    w_idx, n_tied = pick_most_extreme(
        np.array(p_indep), tie_scores=np.array([x[2] for x in pair_info])
    )
    tie_note = f" [同率{n_tied}件]" if n_tied > 1 else ""
    results.append(
        TestResult(
            name,
            "2. 桁間の独立性 (10x10χ²+FDR)",
            pair_info[w_idx][2],
            float(q_indep[w_idx]),
            f"最極端={pair_info[w_idx][0]}桁目-{pair_info[w_idx][1]}桁目 (raw_p={p_indep[w_idx]:.4g}, FDR_q={q_indep[w_idx]:.4g}){tie_note}",
        )
    )

    # (3) 全組み合わせの一様分散検定
    M = 10**n_digits
    full_counts = np.bincount(vals, minlength=M)
    lam = T / M
    x2_full = float(np.sum((full_counts - lam) ** 2 / lam))
    df_full = M - 1
    z_disp = (x2_full - df_full) / np.sqrt(2.0 * df_full)
    p_disp = float(2.0 * stats.norm.sf(abs(z_disp)))
    results.append(
        TestResult(
            name,
            f"3. 全{M}通りの一様分散検定 (Dispersion Z)",
            z_disp,
            p_disp,
            f"X²={x2_full:.1f} (df={df_full}, 最大出現={full_counts.max()}回, 理論λ={lam:.2f})",
        )
    )

    # (4) 前回同桁の連続出現率
    same_digits = int(np.sum(digits[1:] == digits[:-1]))
    total_d = (T - 1) * n_digits
    p_repeat = stats.binomtest(same_digits, n=total_d, p=0.1).pvalue
    results.append(
        TestResult(
            name,
            "4. 前回同桁の連続出現 (二項検定)",
            same_digits / total_d,
            float(p_repeat),
            f"一致={same_digits}/{total_d} ({same_digits / total_d:.2%} vs 理論10.00%)",
        )
    )

    # (5) 不人気フィルター通過率検証（理論値は全数探索の厳密値）
    obs_pass = sum(1 for s in strings if filter_fn(s))
    theo_rate = exact_numbers_filter_rate(n_digits, filter_fn)
    p_filt = stats.binomtest(obs_pass, n=T, p=theo_rate).pvalue
    results.append(
        TestResult(
            name,
            "5. 不人気フィルター通過率 (二項検定・厳密)",
            obs_pass / T,
            float(p_filt),
            f"実測={obs_pass}/{T} ({obs_pass / T:.2%}) vs 理論={theo_rate:.2%}",
        )
    )

    return results


# =============================================================================
# 5. メイン実行
# =============================================================================


def main() -> None:
    parser = argparse.ArgumentParser(
        description="全6種宝くじ 過去当選番号 自動取得＆統計検定ツール"
    )
    parser.add_argument(
        "--only",
        nargs="+",
        choices=list(FALLBACK_SLUGS.keys()),
        default=list(FALLBACK_SLUGS.keys()),
        help="検定対象のくじを指定（デフォルト: 全6種）",
    )
    parser.add_argument(
        "--save-dir",
        type=Path,
        default=None,
        help="取得した生CSVを保存したい場合に指定",
    )
    parser.add_argument(
        "--mc",
        type=int,
        default=80_000,
        help="ロト・ビンゴ5のフィルター理論率推定のモンテカルロ試行数",
    )
    parser.add_argument(
        "--alpha", type=float, default=0.05, help="有意水準（デフォルト: 0.05）"
    )
    args = parser.parse_args()

    print(f"[1/2] データセット一覧を取得中: {DATASETS_INDEX_URL}")
    pages = discover_dataset_pages(DATASETS_INDEX_URL)

    all_results: list[TestResult] = []
    for key in args.only:
        label = LOTTERY_LABELS[key]
        page_url = pages[key]
        print(f"  -> {label}: CSV取得中 ({page_url}) ...", end=" ", flush=True)
        try:
            df = download_csv_dataframe(key, page_url, save_dir=args.save_dir)
            if key == "loto6":
                mat, ids = parse_loto_df(df, 43, 6)
                print(
                    f"{len(mat)}件 (第{ids[0]}回={mat[0].tolist()} .. 第{ids[-1]}回={mat[-1].tolist()})"
                )
                all_results += audit_loto(label, mat, 43, 6, pass_loto6_filter, args.mc)
            elif key == "loto7":
                mat, ids = parse_loto_df(df, 37, 7)
                print(
                    f"{len(mat)}件 (第{ids[0]}回={mat[0].tolist()} .. 第{ids[-1]}回={mat[-1].tolist()})"
                )
                all_results += audit_loto(label, mat, 37, 7, pass_loto7_filter, args.mc)
            elif key == "miniloto":
                mat, ids = parse_loto_df(df, 31, 5)
                print(
                    f"{len(mat)}件 (第{ids[0]}回={mat[0].tolist()} .. 第{ids[-1]}回={mat[-1].tolist()})"
                )
                all_results += audit_loto(
                    label, mat, 31, 5, pass_miniloto_filter, args.mc
                )
            elif key == "bingo5":
                mat, ids = parse_loto_df(df, 40, 8, bingo_mode=True)
                print(
                    f"{len(mat)}件 (第{ids[0]}回={mat[0].tolist()} .. 第{ids[-1]}回={mat[-1].tolist()})"
                )
                all_results += audit_bingo5(mat, args.mc)
            elif key == "numbers4":
                strs, ids = parse_numbers_df(df, 4)
                print(
                    f"{len(strs)}件 (第{ids[0]}回={strs[0]} .. 第{ids[-1]}回={strs[-1]})"
                )
                all_results += audit_numbers(label, strs, 4, pass_numbers4_filter)
            elif key == "numbers3":
                strs, ids = parse_numbers_df(df, 3)
                print(
                    f"{len(strs)}件 (第{ids[0]}回={strs[0]} .. 第{ids[-1]}回={strs[-1]})"
                )
                all_results += audit_numbers(label, strs, 3, pass_numbers3_filter)
        except Exception as e:
            print(f"失敗: {e}")

    if not all_results:
        print("\n検定結果がありません。")
        return

    print("\n[2/2] 統計検定レポート")
    print(f"{'くじ':<10} | {'検定項目':<36} | {'p/q値':>9} | {'判定':<6} | 詳細")
    print("-" * 124)
    for r in all_results:
        verdict = "偏り有*" if r.p_value < args.alpha else "有意差無"
        print(
            f"{r.lottery:<10} | {r.test_name:<36} | {r.p_value:>9.4g} | {verdict:<6} | {r.detail}"
        )


if __name__ == "__main__":
    main()
