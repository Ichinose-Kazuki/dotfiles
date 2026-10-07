inputs@{
  impermanence,
  nixos-hardware,
  raspberry-pi-nix,
  raspi-home-manager,
  raspi-nixpkgs,
  ...
}:

let
  basic-config =
    { pkgs, lib, ... }:
    {
      # bcm2711 for rpi 3, 3+, 4, zero 2 w
      # bcm2712 for rpi 5
      # See the docs at:
      # https://www.raspberrypi.com/documentation/computers/linux_kernel.html#native-build-configuration
      raspberry-pi-nix.board = "bcm2711";
      raspberry-pi-nix.uboot.enable = true;
      networking = {
        useDHCP = false;
        interfaces = {
          # wlan0.useDHCP = true;
          eth0.useDHCP = true;
        };
      };
      hardware = {
        # bluetooth.enable = true;
        raspberry-pi = {
          config = {
            all = {
              base-dt-params = {
                # enable autoprobing of bluetooth driver
                # https://github.com/raspberrypi/linux/blob/c8c99191e1419062ac8b668956d19e788865912a/arch/arm/boot/dts/overlays/README#L222-L224
                # krnbt = {
                #   enable = true;
                #   value = "on";
                # };
              };
              dt-overlays = {
                disable-bt = {
                  enable = true;
                  params = { };
                };
              };
            };
          };
        };
      };
    };
in
raspi-nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
  };
  modules = [
    nixos-hardware.nixosModules.raspberry-pi-3
    raspberry-pi-nix.nixosModules.raspberry-pi
    impermanence.nixosModules.impermanence
    basic-config
    ../raspi3bp
    raspi-home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.kazuki = import ../../users/kazuki/home_raspi.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        host = "raspi3bp";
      };
    }
  ];
}
