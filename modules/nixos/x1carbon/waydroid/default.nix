{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

# Read https://wiki.nixos.org/wiki/Waydroid for usage
# Run `sudo waydroid_script install libndk` to get ARM pkgs working
# waydroid_script: https://github.com/casualsnek/waydroid_script
{
  virtualisation.waydroid.enable = true;
  # Newer kernel versions may need
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # Enable clipboard sharing
  environment.systemPackages = [
    pkgs.wl-clipboard
    inputs.waydroid-script.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
