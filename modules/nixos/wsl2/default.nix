{ ... }:

{
  imports = [
    ./graphics
    ./networking
    ./interop
    ../common/tailscale
  ];

  options.virtualization.docker = {
    enable = true;
  };
}
