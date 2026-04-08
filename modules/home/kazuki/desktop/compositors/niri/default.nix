{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./input.nix
    ./keybindings.nix
    ./layout.nix
    ./niri-tile-to-n.nix
    ../../components/kanshi
    ../../components/swayidle
  ];

  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md
  programs.niri.settings = {
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
    hotkey-overlay.skip-at-startup = false; # todo: true
    prefer-no-csd = true;
  };

  programs.niri.settings.spawn-at-startup = [
    {
      argv = [
        "dbus-update-activation-environment"
        "--systemd"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
      ];
    }
  ];

  # monitors are handled in kanshi
}
