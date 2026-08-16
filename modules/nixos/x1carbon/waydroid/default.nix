{
  config,
  pkgs,
  lib,
  ...
}:

# Read https://wiki.nixos.org/wiki/Waydroid for usage
{
  virtualisation.waydroid.enable = true;
  # Newer kernel versions may need
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable clipboard sharing
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
