{ pkgs, lib, ... }:

{
  programs.plasma = {
    enable = true;
    overrideConfig = true;

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

    # A key binding cannot be set to multiple commands.
    # Delete the default key binding with "***" = "none".
    shortcuts = {
      ksmserver = {
        "Lock Session" = [ "Screensaver" "Meta+Ctrl+L" ];
      };

      kwin = {
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
        "Overview" = "none";
        "Window Close" = "Meta+W";
      };
    };

    workspace = {
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/MilkyWay/contents/images/5120x2880.png";
    };

    kscreenlocker = {
      appearance.wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/MilkyWay/contents/images/5120x2880.png";
    };

    fonts = {
      general = {
        family = "Noto Sans CJK JP";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Hack Nerd Font";
        pointSize = 10;
      };
    };

    # Panels settings causes delay in loading wallpaper after login.
    panels = [{
      height = 30;
      location = "bottom";
      hiding = "autohide";
    }];

    # $HOME/.config/
    configFile = {
      inherit (import ./config/kwinrc.nix) kwinrc;
      inherit (import ./config/fcitx5.nix) "fcitx5/profile";
      inherit (import ./config/globalTheme.nix) "kdedefaults/ksplashrc" "kdedefaults/plasmarc" kdeglobals;
      inherit (import ./config/locale.nix) plasma-localerc;
    };

    # $HOME/.local/share/
    dataFile = {
      inherit (import ./config/dolphin.nix) "dolphin/view_properties/global/.directory";
    };
  };

  # Files that cannot be managed by plasma-manager
  # e.g. plain text files, images, etc.
  xdg.configFile = {
    inherit (import ./config/globalTheme.nix) "kdedefaults/package";
  };
}
