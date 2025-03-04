{
  description = "A very basic flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lix-module,
      home-manager,
      nixos-hardware,
      nixos-wsl,
      raspberry-pi-nix,
      raspi-nixpkgs,
      raspi-home-manager,
      flake-utils,
      impermanence,
      ...
    }:

    {
      # Details: https://nixos.wiki/wiki/Flakes
      nixosModules = {
        common = ./modules/nixos/common;
        x1carbon = ./modules/nixos/x1carbon;
        wsl2 = ./modules/nixos/wsl2;
        tsuyoServer = ./modules/nixos/tsuyoServer;
        raspi3bp = ./modules/nixos/raspi3bp;
      };
      homeManagerModules.kazuki = {
        common = ./modules/home/kazuki/common;
        wsl2 = ./modules/home/kazuki/wsl2;
        tsuyoServer = ./modules/home/kazuki/tsuyoServer;
      };

      nixosConfigurations.x1carbon =
        let
          system = "x86_64-linux";
          overlays = [ inputs.efi-power.overlays.default ];
          pkgs = import nixpkgs {
            inherit system overlays;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = (_: true);
            };
          };
        in
        nixpkgs.lib.nixosSystem {
          # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
          inherit pkgs;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            #! lix
            lix-module.nixosModules.default
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
            ./hosts/x1carbon
            # ! Not needed if using standalone home-manager.
            # ! Import standalone settings
            # home-manager.nixosModules.home-manager
            # {
            #   home-manager.useGlobalPkgs = true;
            #   home-manager.useUserPackages = true;
            #   home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
            # }
          ];
        };

      nixosConfigurations.tsuyoServer =
        let
          system = "x86_64-linux";
          overlays = [ inputs.efi-power.overlays.default ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        nixpkgs.lib.nixosSystem {
          # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
          inherit pkgs;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            # lix-module.nixosModules.default
            ./hosts/tsuyoServer
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kazuki = import ./users/kazuki/home_tsuyoServer.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                host = "tsuyoServer";
              };
            }
          ];
        };

      nixosConfigurations.raspi3bp =
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
            ./hosts/raspi3bp
            raspi-home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.kazuki = import ./users/kazuki/home_raspi.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                host = "raspi3bp";
              };
            }
          ];
        };

      nixosConfigurations.wsl2 = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/wsl2
          (nixos-wsl.outPath + "/modules")
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kazuki = import ./users/kazuki/home_wsl.nix;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              host = "wsl2";
            };
          }
        ];
      };

      nixosConfigurations.diskoTest = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/diskoTest
        ];
      };

      homeConfigurations.kazuki-wsl =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              allowUnfreePredicate = (_: true);
            };
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            host = "standalone";
          };
          # Specify your home configuration module here, for example,
          # the path to your home.nix
          modules = [
            ./users/kazuki/home_wsl.nix
          ];
        };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = (_: true);
          };
        };
      in
      {
        # Formatter used in this directory by `nix fmt`.
        formatter = pkgs.nixpkgs-fmt;
        # Does not work with direnv. https://github.com/NixOS/nixfmt/issues/151
        # formatter = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
        # `nix develop`
        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nixpkgs-fmt ];
        };
      }
    );

  # Run `nix flake metadata [this dir]` to know which "follows" need to be added.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix?ref=refs/tags/v0.4.1";
    raspi-nixpkgs.follows = "raspberry-pi-nix/nixpkgs"; # Avoid rebuilding linux kernel
    raspi-home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "raspi-nixpkgs";
    };
    raspi-nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "raspi-nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    flake-utils.url = "github:numtide/flake-utils";
    efi-power = {
      url = "github:Ichinose-Kazuki/efi-power";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
