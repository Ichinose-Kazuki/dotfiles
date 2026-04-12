{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./debug.nix
    ./input.nix
    ./keybindings.nix
    ./layout.nix
    ./niri-tile-to-n.nix
    ./window-rules.nix
    ../../common
    ../../components/kanshi
    ../../components/swayidle
  ];

  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md
  programs.niri.settings = {
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
    hotkey-overlay.skip-at-startup = true;
    prefer-no-csd = true;
  };

  programs.niri.settings.spawn-at-startup = [
    # Export some important environment to systemd and dbus user env. Variables are from hm sway module (https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/i3-sway/sway.nix).
    (
      let
        dbusImplementation = osConfig.services.dbus.implementation;
        variables = [
          "DISPLAY"
          "WAYLAND_DISPLAY"
          "NIRI_SOCKET"
          "XDG_CURRENT_DESKTOP"
          "XDG_SESSION_TYPE"
          "NIXOS_OZONE_WL"
          "XCURSOR_THEME"
          "XCURSOR_SIZE"
          "QT_SCREEN_SCALE_FACTORS" # For flameshot?
        ];
        systemdActivation =
          {
            broker = [
              "systemctl"
              "--user"
              "import-environment"
            ]
            ++ variables;
            dbus = [
              "${pkgs.dbus}/bin/dbus-update-activation-environment"
              "--systemd"
            ]
            ++ variables;
          }
          .${dbusImplementation};
      in
      {
        argv = systemdActivation;
      }
    )
  ];

  # monitors are handled in kanshi
}
