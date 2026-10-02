{ ... }:

{
  imports = [
    ./tailscale
    ./tsuyoServerPowerButton
  ];

  boot.loader.generic-extlinux-compatible.configurationLimit = 3;
}
