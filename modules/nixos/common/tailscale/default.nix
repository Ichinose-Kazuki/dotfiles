{
  pkgs,
  config,
  lib,
  ...
}:

{
  config = {
    services.tailscale.enable = true;
    systemd.services.tailscaled.wantedBy = lib.mkForce [ ];
  };
}
