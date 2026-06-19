{ pkgs, lib, config, ... }:
{
  # stable version
  # https://lix.systems/add-to-config/
  # Guarded by myModule.lix (derived off on SBC hosts whose pinned nixpkgs
  # lacks pkgs.lixPackageSets).
  config = lib.mkIf config.myModule.lix {
    nix.package = pkgs.lixPackageSets.stable.lix;
  };
}
