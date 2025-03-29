{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true; # enable Hyprland
    withUWSM = true; # recommended session manager on systemd-based systems
  };

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
