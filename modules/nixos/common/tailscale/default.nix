{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = lib.mkIf config.myModule.tailscale {
    services.tailscale.enable = true;
    systemd.services.tailscaled.wantedBy = lib.mkForce [ ];
  };
}
