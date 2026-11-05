# NoSmallMono

JuliaMono 0.63.2 から、小さく描かれている囲み英数字
（Enclosed Alphanumerics / Enclosed Alphanumeric Supplement）を cmap から
削除した派生フォント。Regular / Bold / Italic / Light / Medium / SemiBold /
ExtraBold / Black と各 Italic の全 14 スタイルを同じ条件で処理している。

JuliaMono の SIL Open Font License には Reserved Font Name `JuliaMono` が
指定されているため、派生フォントのファミリー名には `JuliaMono` を使わず
`NoSmallMono` としている。

## 削除条件

次の 2 条件を満たす文字を全 Unicode cmap サブテーブルから削除する。

- Unicode のブロックが Enclosed Alphanumerics または
  Enclosed Alphanumeric Supplement
- グリフのインクの幅と高さがともに 0.5 em 未満

削除対象は Regular から計算し、全スタイルに同じコードポイントを適用する。
これにより Bold などでインクがわずかに大きくなる文字も、ファミリー全体で
同じように削除される。

削除される文字は 66 文字。①-⑳、⓪、❶-❿ などを含む。矢印、°、幾何学図形、
句読点、文字、結合記号、罫線、点字は残る。

## フォールバック

削除された丸数字は、ターミナルの次のフォールバック（Unifont）で表示される。
Ghostty は Enclosed Alphanumerics と Dingbats を記号として扱い、1 セルに
収まるよう縮小するため、JuliaMono の小さい丸数字より大きく表示される。

## 使い方

`pkgs/overlay.nix` により、全ホストで次の名前が使える。

```nix
pkgs.julia-mono-no-small
```

フォントファミリー名は `NoSmallMono`。monospace のリストでは `JuliaMono` を
`NoSmallMono` に置き換える。

```nix
fontconfig.defaultFonts.monospace = [
  "IntoneMono Nerd Font Mono"
  "Noto Sans Mono CJK JP NoWiderThanIntoneMono"
  "NoSmallMono"
  "Unifont"
  "Unifont Upper"
];
```

## 入力

`nixpkgs` の `julia-mono` パッケージ（JuliaMono 0.63.2）の
`share/fonts/truetype/JuliaMono-*.ttf`。

## 再現性

`filter_fonts.py` は `TTFont(..., recalcBBoxes=False, recalcTimestamp=False)`
を使うため、`head.modified` は入力の値のまま保たれる。同じ入力と同じ
fontTools ならビルド結果は決定的になる。

字形データ（glyf / loca）、GSUB/GPOS、hmtx/vmtx などの表は変更しない。
変更されるのは `cmap`、`name`、および `head.checkSumAdjustment` のみ。

## ライセンス

元フォントは SIL Open Font License 1.1（Reserved Font Name `JuliaMono`）。
ライセンス本文は `$out/share/licenses/julia-mono-no-small/LICENSE` に同梱している。
派生フォントは予約名 `JuliaMono` を使用せず、`NoSmallMono` を名乗る。
