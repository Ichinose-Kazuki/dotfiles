{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
  ];

  # nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  niri-flake.cache.enable = false; # not working with nixos-unstable

  environment.variables.NIXOS_OZONE_WL = "1";
  environment.systemPackages = with pkgs; [
    wl-clipboard
    wayland-utils
    libsecret
    xwayland-satellite
  ];

  security.soteria.enable = true;
}
