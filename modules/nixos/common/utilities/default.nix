{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  # `services.cockpit.allowed-origins` was added in a NixOS release after the
  # pinned raspi-nixpkgs. Guard it so old-nixpkgs hosts don't fail with
  # "option does not exist" even when cockpit is disabled (mkIf false still
  # checks the attrset type in old nixpkgs).
  hasCockpitAllowedOrigins = lib.hasAttrByPath [ "services" "cockpit" "allowed-origins" ] options;
in
{
  # Cockpit is guarded: its options (e.g. allowed-origins) require a recent
  # nixpkgs, which the SBC hosts do not have. Driven by myModule.cockpit
  # (derived: on for non-sbc machines).
  services.cockpit = lib.mkIf config.myModule.cockpit (
    {
      enable = true;
    }
    // lib.optionalAttrs hasCockpitAllowedOrigins {
      allowed-origins = [ "http://localhost:9090" ];
    }
  );

  environment.systemPackages = with pkgs; [
    psmisc
    socat
  ];
}
