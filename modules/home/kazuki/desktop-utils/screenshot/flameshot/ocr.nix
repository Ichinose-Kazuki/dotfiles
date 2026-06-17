{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  langs = [
    "eng"
    "jpn"
  ];
  lang-arg = builtins.concatStringsSep "+" langs;

  tesseract-with-lang = pkgs.tesseract.override {
    enableLanguages = langs;
  };

  flameshot-ocr-script = pkgs.writeShellScriptBin "flameshot-ocr" ''
    IMAGE_PATH=$1

    if [ -z "$IMAGE_PATH" ]; then
        ${pkgs.libnotify}/bin/notify-send "Flameshot OCR" "エラー: 画像パスが渡されていません。"
        exit 1
    fi

    OCR_TEXT=$(${tesseract-with-lang}/bin/tesseract -l ${lang-arg} "$IMAGE_PATH" stdout 2>/dev/null)

    if [ -n "$OCR_TEXT" ]; then
        echo "$OCR_TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
        ${pkgs.libnotify}/bin/notify-send "Flameshot OCR" "テキストをクリップボードにコピーしました！"
    else
        ${pkgs.libnotify}/bin/notify-send "Flameshot OCR" "文字を認識できませんでした。"
    fi
  '';

  ocr-standalone-script = pkgs.writeShellScriptBin "ocr" ''
    TMP_IMG=$(mktemp --suffix=.png)

    ${config.services.flameshot.package}/bin/flameshot gui --raw > "$TMP_IMG"

    if [ -s "$TMP_IMG" ]; then
        ${flameshot-ocr-script}/bin/flameshot-ocr "$TMP_IMG"
    fi

    rm -f "$TMP_IMG"
  '';

  # GUIの「アプリケーションで開く」一覧に表示させるための .desktop エントリ
  flameshot-ocr-desktop = pkgs.makeDesktopItem {
    name = "flameshot-ocr";
    desktopName = "Extract Text (Tesseract OCR)"; # Flameshot上で表示される名前
    exec = "${flameshot-ocr-script}/bin/flameshot-ocr %f";
    terminal = false;
    type = "Application";
    categories = [ "Utility" ];
  };

in
{
  config = lib.mkIf (builtins.elem "flameshot" osConfig.myModule.home.screenshots) {
    home.packages = [
      flameshot-ocr-script
      flameshot-ocr-desktop
      ocr-standalone-script
      tesseract-with-lang
    ];
  };
}
