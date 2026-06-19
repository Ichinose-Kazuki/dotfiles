{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Cockpit is guarded: its options (e.g. allowed-origins) require a recent
  # nixpkgs, which the SBC hosts do not have. Driven by myModule.cockpit
  # (derived: on for non-sbc machines).
  services.cockpit = lib.mkIf config.myModule.cockpit {
    enable = true;
    allowed-origins = [ "http://localhost:9090" ];
  };

  environment.systemPackages = with pkgs; [
    psmisc
    socat
  ];
}
