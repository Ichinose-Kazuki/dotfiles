{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  imports = [
    ./settings.nix
    ./palette.nix
    ./plugins.nix
    ./wallpaper.nix
  ];

  programs.noctalia = {
    enable = true;
    package = pkgs.noctalia;
    # The shell is started by niri's spawn-at-startup, matching the previous
    # v4 setup, so the systemd user service is left disabled.
    systemd.enable = false;
  };

  home.packages = with pkgs; [
    # Dependency for clipboard auto-paste.
    wtype
  ];
}
