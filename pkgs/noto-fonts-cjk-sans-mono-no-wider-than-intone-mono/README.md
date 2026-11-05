# Noto Sans Mono CJK JP NoWiderThanIntoneMono

Noto Sans Mono CJK JP から、ターミナルが 1 セルとして扱う文字のうち、
IntoneMono の 1 セルより広い送り幅を持つものを cmap から削除した
Regular / Bold の OTF を生成するパッケージ。

IntoneMono NFM の送り幅は 614 / 1000 em なので、Noto の 1000 units/em では
1 セル = 614 units になる。

## 収録物

| ファイル | 内容 |
|---|---|
| `NotoSansMonoCJKjp-Regular-NoWiderThanIntoneMono.otf` | Regular |
| `NotoSansMonoCJKjp-Bold-NoWiderThanIntoneMono.otf` | Bold |

- ファミリー名: `Noto Sans Mono CJK JP NoWiderThanIntoneMono`
- フルネーム: `Noto Sans Mono CJK JP NoWiderThanIntoneMono`（Regular）/
  `Noto Sans Mono CJK JP NoWiderThanIntoneMono Bold`（Bold）
- PostScript 名: `NotoSansMonoCJKjpNoWiderThanIntoneMono-Regular` / `-Bold`
- 収録文字数: Regular は 44,810 文字から 1,221 文字を削除して 43,589 文字。
  Bold は 44,810 文字から 1,333 文字を削除して 43,477 文字。

## 加工内容

元ファイル（公式リリース `Sans2.004` の `Sans/Mono/`）から、次の 2 条件を
両方満たす文字コードを全 Unicode cmap サブテーブルから削除した。

- East_Asian_Width が `W`（Wide）でも `F`（Fullwidth）でもない
- 送り幅が 614 units（IntoneMono の 1 セル）より広い

Wide / Fullwidth の文字は、ターミナルが 2 セルを割り当てるため残す。
Regular の削除内訳は A 696、N 473、H 52。Bold は A 739、N 541、H 52、Na 1。
U+0429 `Щ`（976 units）は削除され、U+0410 `А`（608 units）は残る。

字形データ（CFF の charstrings）、GSUB/GPOS、hmtx/vmtx、VORG などの表は
変更していない。変更されるのは `cmap`、`name`、CFF の top dict にある
`FamilyName` / `FullName`、および `head.checkSumAdjustment`。

## 入力

公式リポジトリ `notofonts/noto-cjk` のタグ `Sans2.004`
（コミット `523d033d6cb47f4a80c58a35753646f5c3608a78`）の `Sans/Mono/`。

| ファイル | SHA-256 |
|---|---|
| `NotoSansMonoCJKjp-Regular.otf` | `4d01725be822d144cf9a56ade981e6fb920cd7a610b8fc24cc601a920beea5b9` |
| `NotoSansMonoCJKjp-Bold.otf` | `dfdffe149bc6cbf52860dabd8b8dadbca40ae87a4fbe143b55c0258db2dadfb8` |

IntoneMono の基準値は、`nerd-fonts-intone-mono` 3.5.0+1.4.0 の
`IntoneMonoNerdFontMono-Regular.ttf`（upm 1000、`A` の送り幅 614）による。

## ビルドと使い方

`pkgs/overlay.nix` により、全ホストで次の名前が使える。

```nix
pkgs.noto-fonts-cjk-sans-mono-no-wider-than-intone-mono
```

フォントとして使う場合は、たとえば次のように追加する。

```nix
fonts.packages = [
  pkgs.noto-fonts-cjk-sans-mono-no-wider-than-intone-mono
];

fontconfig.defaultFonts.monospace = [
  "Noto Sans Mono CJK JP NoWiderThanIntoneMono"
];
```

## 再現性

`filter_fonts.py` は `TTFont(..., recalcTimestamp=False)` を使うため、
`head.modified` は入力の値のまま保たれる。同じ入力と同じ fontTools なら
ビルド結果は決定的になる。

## ライセンス

元フォントは SIL Open Font License 1.1（予約フォント名なし）。ライセンス本文は
`$out/share/licenses/noto-fonts-cjk-sans-mono-no-wider-than-intone-mono/LICENSE`
に同梱している。`DSIG` 表は元のまま残しており、加工により署名としては無効に
なっているが、Windows・macOS・Linux のいずれも表示時に検証しない。
