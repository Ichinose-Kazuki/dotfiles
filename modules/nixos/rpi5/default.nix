{ ... }:

{
  imports = [
    ./tailscale
    ./tsuyoServerPowerButton
  ];

  boot.loader.raspberry-pi.configurationLimit = 3;
}
