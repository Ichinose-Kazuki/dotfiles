{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

# Great config from https://github.com/purplesmoke05/dotnix/blob/73f87887970a637a1c84385bfc7179388059257b/hosts/nixos/common/home-manager.nix
let
  # Mozc config DB / Mozc 設定 DB
  # Build config1.db from textproto and keymap sources. / textproto とキーマップから config1.db を生成する。
  # How to generate config-base.textproto from the current config:
  # (1) Get config.proto from https://raw.githubusercontent.com/fcitx/mozc/57e67f2a25e4c0861e0e422da0c7d4c232d89fcc/src/protocol/config.proto (rev used in fcitx5-mozc package)
  # (2) Generate: `protoc --decode=mozc.config.Config config.proto < ~/.config/mozc/config1.db > config.txt`
  # (3) Remove `custom_keymap_table` line. Copy & paste its value to keymap.tsv
  mozcConfigDb =
    let
      mozcProtoRoot = "${pkgs.fcitx5-mozc-ut.src}/src";
    in
    pkgs.runCommand "mozc-config1.db"
      {
        nativeBuildInputs = with pkgs; [
          gawk
          protobuf
        ];
      }
      ''
        keymap_table="$(
          awk '{
            gsub(/\\/,"\\\\");
            gsub(/"/,"\\\"");
            gsub(/\t/,"\\t");
            printf "%s\\n", $0;
          }' ${./keymap.tsv}
        )"

        {
          cat ${./config-base.textproto}
          printf 'custom_keymap_table: "%s"\n' "$keymap_table"
        } > config.textproto

        protoc \
          -I ${mozcProtoRoot} \
          --encode=mozc.config.Config \
          ${mozcProtoRoot}/protocol/config.proto \
          < config.textproto > "$out"
      '';
in
{
  # Mozc database / Mozc データベース
  # Store Mozc's durable keymap and behavior settings. / Mozc の持続設定とキーマップを保持する。
  xdg.configFile."mozc/config1.db" = {
    force = true;
    source = mozcConfigDb;
  };
}
