{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.cockpit = {
    enable = true;
    allowed-origins = [ "http://localhost:9090" ];
  };

  environment.systemPackages = with pkgs; [
    socat
  ];
}
