# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{

  imports = with inputs; [
    nixos-hardware.nixosModules.raspberry-pi-5
    nix-index-database.nixosModules.nix-index
    disko.nixosModules.disko
    ./disko.nix
    self.nixosModules.common
    self.nixosModules.rpi5
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # default config values:
  # https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/5/default.nix
  # https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/common/firmware.nix#L192

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;
  };

  # Use the mainline kernel instead of nixos-hardware's vendored "linux-rpi"
  # kernel. The vendored kernel has no binary cache anywhere
  # (see nixos-hardware#325), so it is rebuilt from source on every nixpkgs
  # update; the mainline kernel ships prebuilt in cache.nixos.org. The
  # raspberry-pi-5 module picks the matching initrd modules for whichever
  # kernel is selected here (it names the RP1/PCIe drivers differently for
  # mainline vs the vendor fork), so no module list is duplicated here.
  boot.kernelPackages = pkgs.linuxPackages;

  # # Limit journal size
  # services.journald.extraConfig = ''
  #   SystemMaxUse=50M
  # '';
  # # Store log on RAM.
  # services.journald.storage = "volatile";

  networking.hostName = "rpi5"; # Define your hostname.

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kazuki = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wol # Wake-on-LAN
  ];

  # setup manual: https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_5
  # U-Boot does not support NVMe boot as of writing this config.
}
// {
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  # Using lib.mkForce because it conflicts with nixpkgs' value.
  system.stateVersion = lib.mkForce "25.05"; # Did you read the comment?
}
