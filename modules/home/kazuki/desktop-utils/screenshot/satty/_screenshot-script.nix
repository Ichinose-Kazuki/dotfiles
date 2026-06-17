{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

pkgs.writeShellApplication {
  name = "screenshot-sh";

  runtimeInputs = with pkgs; [
    coreutils
    grim
    jq
    niri
    satty
    slurp
    wl-clipboard
  ];

  text = ''
    set -o errexit
    set -o pipefail
    set -o nounset

    MODE="''${1:-region}"

    case "''${MODE}" in
    region)
      grim -g "$(slurp -d)" -
      ;;
    window)
      niri msg action screenshot-window
      sleep 0.5
      wl-paste --type image/png
      ;;
    monitor-focused)
      grim -o "$(niri msg --json focused-output | jq --raw-output .name)" -
      ;;
    monitor-all)
      grim -
      ;;
    *)
      echo "'${"$"}{MODE}' is not supported, aborting!" >&2
      exit 1
      ;;
    esac | satty --filename - --output-filename "''${XDG_PICTURES_DIR}/screenshot-%+.png"
  '';
}
