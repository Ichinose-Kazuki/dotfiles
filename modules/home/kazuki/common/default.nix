{ lib, ... }:

{
  # Force disable xdg autostart since it conflicts with systemd daemons.
  xdg.autostart.enable = lib.mkForce false;
}
