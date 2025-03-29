{ inputs, pkgs, ... }:

{
  programs.hyprland.enable = true; # enable Hyprland

  environment.systemPackages = with pkgs; [
    # ... other packages
    kitty # required for the default Hyprland config
  ];

  # Optional, hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Set hyprland as the default session in the display manager.
  services.displayManager.defaultSession = "hyprland";
}
