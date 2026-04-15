{
  config,
  pkgs,
  lib,
  ...
}:

let
  obsidian-app-id-fixed = pkgs.obsidian.overrideAttrs (old: {
    # asar と jq を追加
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkgs.asar
      pkgs.jq
    ];

    postFixup = (old.postFixup or "") + ''
      echo "Patching Obsidian app.asar for Wayland app_id..."
      cd $out/share/obsidian

      # ベースとなるディレクトリを作成
      mkdir -p app.asar.unpacked
      chmod -R +w app.asar.unpacked || true

      # [魔法のループ]
      # asar extract が ENOENT (ファイル不在) で失敗する限り、
      # エラーログからパスを抽出して空のダミーを作り続ける
      MAX_RETRIES=20
      count=0
      while ! asar extract app.asar tmp-app 2> asar_error.log; do
        # エラーログから ' ' で囲まれたファイルパスだけを抽出
        MISSING_FILE=$(grep "ENOENT" asar_error.log | sed -n "s/.*open '\([^']*\)'.*/\1/p" | head -n 1)

        if [ -n "$MISSING_FILE" ]; then
          echo "Mocking missing unpacked file: $MISSING_FILE"
          mkdir -p "$(dirname "$MISSING_FILE")"
          touch "$MISSING_FILE"
        else
          echo "Unrecognized extraction error:"
          cat asar_error.log
          exit 1
        fi

        count=$((count+1))
        if [ $count -gt $MAX_RETRIES ]; then
          echo "Too many missing files. Aborting to prevent infinite loop."
          exit 1
        fi
      done

      echo "ASAR extraction successful! Injecting desktopName..."

      # package.json に "desktopName": "Obsidian" を注入
      jq '. + {"desktopName": "Obsidian"}' tmp-app/package.json > tmp.json
      mv tmp.json tmp-app/package.json

      # 編集した内容で app.asar を再圧縮
      asar pack tmp-app app.asar

      # 一時ファイルのお掃除
      rm -rf tmp-app asar_error.log app.asar.unpacked
    '';
  });
in
{
  imports = [
    ./community-plugins
    ./core-plugins
    ./vaults
  ];

  programs.obsidian = {
    enable = true;
    package = obsidian-app-id-fixed;
  };
}
