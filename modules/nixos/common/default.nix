{ lib, ... }:

{
  imports = [
    ./basic
    ./compatibility
    ./lix
    ./utilities
    ./zsh
  ];

  # Force disable xdg autostart since it conflicts with systemd daemons.
  xdg.autostart.enable = lib.mkForce false;
}
