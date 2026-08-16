{
  config,
  pkgs,
  lib,
  ...
}:

{
  virtualisation.waydroid.enable = true;
  # Newer kernel versions may need
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable clipboard sharing
  environment.systemPackages = [ pkgs.wl-clipboard ];
}
