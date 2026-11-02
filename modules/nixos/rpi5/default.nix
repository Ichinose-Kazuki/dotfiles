{ ... }:

{
  imports = [
    ../keyring
    ./ssh
    ./tailscale
    ./tsuyoServerPowerButton
  ];

  boot.loader.raspberry-pi.configurationLimit = 3;
}
