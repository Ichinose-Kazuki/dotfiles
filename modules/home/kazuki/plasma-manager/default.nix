{ pkgs, lib, ... }:

{
  programs.plasma = {
    enable = true;

    # Touchpad
    input.touchpads = [
      {
        name = "SYNA8017:00 06CB:CEB2 Touchpad";
        enable = true;
        tapToClick = false;
        vendorId = "06CB";
        productId = "CEB2";
      }
    ];

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };

    workspace = {
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/MilkyWay/contents/images/5120x2880.png";
    };

    # $HOME/.config/
    configFile = {
      inherit (import ./config/kwinrc.nix) kwinrc;
      inherit (import ./config/fcitx5.nix) "fcitx5/profile";
    };

    # $HOME/.local/share/
    dataFile = {
      inherit (import ./config/dolphin.nix) "dolphin/view_properties/global/.directory";
    };
  };
}
