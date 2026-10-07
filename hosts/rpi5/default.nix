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

let
  # The Raspberry Pi kernel's macb driver, built out-of-tree against the
  # mainline kernel (see ./macb-rpi/default.nix).
  macbRpi = pkgs.callPackage ./macb-rpi {
    kernel = config.boot.kernelPackages.kernel;
  };
in
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

  # Bind the Raspberry Pi macb driver to the RP1 Ethernet device in place of
  # the built-in mainline macb. The built-in driver probes the device first, so
  # a unit unbinds it and binds macb_rpi once the module is loaded.
  boot.extraModulePackages = [ macbRpi ];
  boot.kernelModules = [ "macb_rpi" ];
  systemd.services.macb-rpi = {
    description = "Bind the out-of-tree Raspberry Pi macb driver to RP1 Ethernet";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      dev=1f00100000.ethernet
      if [ -e /sys/bus/platform/drivers/macb_rpi ] && [ -e /sys/bus/platform/devices/$dev ]; then
        echo "$dev" > /sys/bus/platform/drivers/macb/unbind || true
        echo "$dev" > /sys/bus/platform/drivers/macb_rpi/bind || true
      fi
    '';
  };

  # With U-Boot, load the device tree from the NixOS generation (the mainline
  # kernel's bcm2712-rpi-5-b.dtb) instead of the firmware's vendor device tree.
  # The vendor tree describes the RP1 I/O controller the way the Raspberry Pi
  # kernel expects (a "simple-bus" node directly under the PCIe controller,
  # with no "pci1de4,1" nexus node), which the mainline rp1_pci driver cannot
  # bind, so Ethernet/USB behind RP1 never comes up. The mainline tree carries
  # the nexus node and also enables the external PCIe port, so NVMe root keeps
  # working.
  boot.loader.generic-extlinux-compatible.useGenerationDeviceTree = true;

  # The switch above drops the firmware's config.txt PCIe dtparams, in
  # particular pciex1_gen=3, and the mainline tree caps the external port at
  # Gen2. Restore Gen3 with an overlay applied to the generation tree.
  hardware.deviceTree.overlays = [
    {
      name = "rpi5-pcie-gen3";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "raspberrypi,5-model-b", "brcm,bcm2712";
        };
        &{/axi/pcie@1000110000} {
          max-link-speed = <3>;
        };
      '';
    }
  ];

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
