# Noto Sans Mono CJK JP NoWideAmbiguous

Noto Sans Mono CJK JP から、東アジア幅が「曖昧（Ambiguous）」で、かつ
フォント内で全角幅（1000 units）で描かれている文字を cmap から削除した
Regular / Bold の OTF を生成するパッケージ。

## 収録物

| ファイル | 内容 |
|---|---|
| `NotoSansMonoCJKjp-Regular-NoWideAmbiguous.otf` | Regular |
| `NotoSansMonoCJKjp-Bold-NoWideAmbiguous.otf` | Bold |

- ファミリー名: `Noto Sans Mono CJK JP NoWideAmbiguous`
- フルネーム: `Noto Sans Mono CJK JP NoWideAmbiguous`（Regular）/
  `Noto Sans Mono CJK JP NoWideAmbiguous Bold`（Bold）
- PostScript 名: `NotoSansMonoCJKjpNoWideAmbiguous-Regular` / `-Bold`
- 収録文字数: 44,810 文字から 618 文字を削除して 44,192 文字

曖昧幅でも全角でない文字（ギリシャ文字・キリル文字など）は残している。
字形データ（CFF の charstrings）、GSUB/GPOS、hmtx/vmtx、VORG などの表は
変更しない。変更されるのは `cmap`、`name`、CFF の top dict にある
`FamilyName` / `FullName`、および `head.checkSumAdjustment`。

## 入力

公式リポジトリ `notofonts/noto-cjk` のタグ `Sans2.004`
（コミット `523d033d6cb47f4a80c58a35753646f5c3608a78`）の `Sans/Mono/`。

| ファイル | SHA-256 |
|---|---|
| `NotoSansMonoCJKjp-Regular.otf` | `4d01725be822d144cf9a56ade981e6fb920cd7a610b8fc24cc601a920beea5b9` |
| `NotoSansMonoCJKjp-Bold.otf` | `dfdffe149bc6cbf52860dabd8b8dadbca40ae87a4fbe143b55c0258db2dadfb8` |

## ビルドと使い方

`pkgs/overlay.nix` により、全ホストで次の名前が使える。

```nix
pkgs.noto-fonts-cjk-sans-mono-no-wide-ambiguous
```

フォントとして使う場合は、たとえば次のように追加する。

```nix
fonts.packages = [
  pkgs.noto-fonts-cjk-sans-mono-no-wide-ambiguous
];

fontconfig.defaultFonts.monospace = [
  "Noto Sans Mono CJK JP NoWideAmbiguous"
];
```

## 再現性

`filter_fonts.py` は `TTFont(..., recalcTimestamp=False)` を使うため、
`head.modified` は入力の値のまま保たれる。同じ入力と同じ fontTools なら
ビルド結果は決定的になる。

## ライセンス

元フォントは SIL Open Font License 1.1（予約フォント名なし）。ライセンス本文は
`$out/share/licenses/noto-fonts-cjk-sans-mono-no-wide-ambiguous/LICENSE` に
同梱している。`DSIG` 表は元のまま残しており、加工により署名としては無効に
なっているが、Windows・macOS・Linux のいずれも表示時に検証しない。
