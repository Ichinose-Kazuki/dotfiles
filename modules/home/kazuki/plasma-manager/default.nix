{ pkgs, ... }:

{
  programs.plasma = {
    enable = true;

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };

    configFile = {
      inherit (import ./config/kwinrc.nix) kwinrc;
      inherit (import ./config/fcitx5.nix) "fcitx5/profile";
      inherit (import ./config/dolphin.nix) "../.local/share/dolphin/view_properties/global/.directory";
    };
  };
}
