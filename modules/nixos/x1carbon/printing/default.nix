{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.myModule.hardware.printing {
    # Enable CUPS to print documents.
    services.printing = {
      enable = true;
    };
    systemd.services.printing.wantedBy = lib.mkForce [ ];

    # Enable Avahi to discover printers on the network.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
    systemd.services.avahi.wantedBy = lib.mkForce [ ];
  };
}
