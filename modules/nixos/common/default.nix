{ lib, ... }:

{
  imports = [
    ./basic
    ./compatibility
    ./lix
    ./lib # これだけ意味が違って良くない。なんとかする
    ./overlays.nix
    ./utilities
    ./zsh
  ];

  # Force disable xdg autostart since it conflicts with systemd daemons.
  xdg.autostart.enable = lib.mkForce false;
}
