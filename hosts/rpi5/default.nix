# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual ('nixos-help').

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # The vendored kernel is built by nixos-raspberrypi's own (pinned) nixpkgs, so
  # it does not expose every attribute this system's nixpkgs modules read. Give
  # it those attributes here, rather than switching the whole system to that
  # nixpkgs (which would change the shared modules and home-manager setup).
  baseKernel =
    inputs.nixos-raspberrypi.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5.kernel;
  kernelExtra = {
    # This kernel ships its device trees under `$out/dtbs`.
    buildDTBs = true;
    # Kernel image name inside the kernel output (aarch64 uses "Image").
    target = "Image";
  };
  # The `boot.kernelPackages` option re-derives the kernel through `.override`,
  # which would drop the attributes above, so wrap `override` to re-add them.
  patchedKernel = baseKernel // kernelExtra // {
    override = args: (baseKernel.override args) // kernelExtra;
  };
in
{
  imports = with inputs; [
    # Vendor (raspberrypi/linux) kernel, firmware and device trees, together
    # with the board support (RP1 I/O controller, Ethernet, display) that the
    # mainline kernel does not carry.
    nixos-raspberrypi.nixosModules."raspberry-pi-5".base
    nix-index-database.nixosModules.nix-index
    disko.nixosModules.disko
    ./disko.nix
    self.nixosModules.common
    self.nixosModules.rpi5
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # The vendored kernel is built by nixos-raspberrypi's own (pinned) nixpkgs,
  # which is older than this system's nixpkgs. Modules here read kernel
  # attributes that older nixpkgs' kernel builder did not set, so rebuild the
  # kernel package set around a kernel that carries them.
  boot.kernelPackages = lib.mkForce (pkgs.linuxPackagesFor patchedKernel);

  # Let the Raspberry Pi firmware load the kernel, initrd and device trees
  # directly, without U-Boot. This puts the firmware partition, which holds
  # them, on the NVMe drive: U-Boot cannot read NVMe, whereas the firmware can.
  # The board's EEPROM boot order must list NVMe for the drive to be used.
  boot.loader.raspberry-pi.bootloader = "kernel";

  # Enable the external PCIe port and run it at Gen 3. These are firmware
  # config.txt parameters applied to the device tree.
  hardware.raspberry-pi.config.all = {
    options.avoid_warnings = {
      enable = true;
      value = true;
    };
    base-dt-params = {
      pciex1 = {
        enable = true;
        value = "on";
      };
      pciex1_gen = {
        enable = true;
        value = 3;
      };
    };
  };

  networking.hostName = "rpi5"; # Define your hostname.

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.kazuki = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable 'sudo' for the user.
  };

  # List packages installed in the system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wol # Wake-on-LAN
    # rpi-eeprom-config / rpi-eeprom-update for setting the EEPROM boot order
    # to boot the firmware partition from NVMe.
    raspberrypi-eeprom
  ];
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
