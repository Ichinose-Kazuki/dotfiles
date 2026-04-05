{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  # Workaround for broken hyprland-plugins package
  hyprland-plugins-src = builtins.fetchGit {
    url = "https://github.com/hyprwm/hyprland-plugins.git";
    rev = "b85a56b9531013c79f2f3846fd6ee2ff014b8960";
  };
  hyprbars = pkgs.callPackage "${hyprland-plugins-src}/hyprbars" {
    hyprland = pkgs.hyprland; # hyprland in the package's flake.nix is outdated.
  };
in
{
  wayland.windowManager.hyprland = {
    plugins = with pkgs; [
      # hyprbars
    ];

    settings.plugin = {
      # # https://github.com/hyprwm/hyprland-plugins/tree/main/hyprbars
      # hyperbars = {
      #   enabled = true;
      #   hyprbars-button = [
      #     ",10, , hyprctl dispatch killactive, rgb(636465)"
      #     ",10, , hyprctl dispatch fullscreen 1, rgb(636465)"
      #     ",10, , hyprctl dispatch togglefloating, rgb(636465)"
      #   ];
      #   on_double_click = "hyprctl dispatch fullscreen 1";
      # };
    };
  };

}
