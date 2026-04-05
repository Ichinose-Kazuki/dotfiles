{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./keybindings.nix
  ];

  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md
  programs.niri.settings = {
    screenshot-path = "~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png";
    hotkey-overlay.skip-at-startup = false; # todo: true
    prefer-no-csd = true;
  };

  programs.niri.settings.spawn-at-startup = [ ];

  # monitors are handled in kanshi
}
