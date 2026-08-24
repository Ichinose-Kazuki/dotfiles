{
  pkgs,
  lib,
  inputs,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./ocr.nix
    ./window-rule.nix
  ];

  services.flameshot = {
    enable = true;
    settings = {
      General = {
        disabledTrayIcon = true;
        showAbortNotification = false;
        showStartupLaunchMessage = false;
      };
    };
  };

  # https://github.com/flameshot-org/flameshot/blob/master/docs/Sway%20and%20wlroots%20support.md
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr # For taking screenshots
      xdg-desktop-portal-gtk # Fallback for file picker
    ];

    # Portal mapping for niri session
    config.niri = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Screencast" = "wlr";
      "org.freedesktop.impl.portal.Screenshot" = "wlr";
    };
  };
  # Provide info to xdg portal
  xdg.dataFile."applications/org.flameshot.Flameshot.desktop".source =
    "${config.services.flameshot.package}/share/applications/org.flameshot.Flameshot.desktop";

  # Dependencies
  home.packages = with pkgs; [
    grim
  ];
}
