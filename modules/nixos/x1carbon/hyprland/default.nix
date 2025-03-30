# From https://github.com/turtton/dotnix/blob/daa44ea1c09d16a9ecfcd610b66d7a5d5dbc1708/os/wm/hyprland.nix

{ inputs, system, ... }:
{
  imports = [ inputs.hyprland.nixosModules.default ];
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
  };
  programs.hyprlock.enable = true;
  security.pam.services =
    let
      enableKeyrings = {
        enableGnomeKeyring = true;
        kwallet.enable = true;
      };
    in
    {
      login = enableKeyrings;
      hyprlock = enableKeyrings;
    };
  # Used by hyprpanel
  services = {
    upower.enable = true;
    power-profiles-daemon.enable = true;
  };
}

# { inputs, pkgs, ... }:

# {
#   programs.hyprland = {
#     enable = true; # enable Hyprland
#     withUWSM = true; # recommended session manager on systemd-based systems
#   };

#   services.hypridle.enable = true;
#   programs.hyprlock.enable = true;

#   # Optional, hint Electron apps to use Wayland:
#   environment.sessionVariables.NIXOS_OZONE_WL = "1";
# }
