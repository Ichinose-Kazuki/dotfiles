{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./colors.nix
    ./plugins.nix
    ./settings.nix
    ./wallpapers.nix
  ];

  # available options: https://github.com/noctalia-dev/noctalia-shell/blob/main/nix/home-module.nix
  programs.noctalia-shell = {
    enable = true;
    systemd.enable = false; # deprecated
    # Use the system nixpkgs build of noctalia-shell so its Qt and graphics
    # libraries match the system. The flake input's own pinned nixpkgs would
    # otherwise mix an older libdrm/mesa with the system, leaving EGL
    # unavailable and the shell unable to draw.
    package = pkgs.noctalia-shell;
  };

  home.packages = with pkgs; [
    # Dependency for clipboard auto-paste
    wtype
  ];
}
