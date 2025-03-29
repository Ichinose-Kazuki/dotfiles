{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true; # enable Hyprland
    withUWSM = true; # recommended session manager on systemd-based systems
  };

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
