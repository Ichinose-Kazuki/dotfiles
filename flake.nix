{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = inputs @ { self, nixpkgs, lix-module, home-manager, nixos-hardware, nixos-wsl, ... }:
    let
      system = "x86_64-linux"; # Check flake-utils: https://github.com/numtide/flake-utils
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_: true);
        };
      };
    in
    {
      formatter.${system} = pkgs.nixpkgs-fmt;
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.nixpkgs-fmt ];
      };
      nixosModules = {
        common = ./modules/nixos/common;
        x1carbon = ./modules/nixos/x1carbon;
        wsl2 = ./modules/nixos/wsl2;
        raspi3bp = ./modules/nixos/raspi3bp;
      };
      homeManagerModules.kazuki = {
        common = ./modules/home/kazuki/common;
        wsl2 = ./modules/home/kazuki/wsl2;
      };

      nixosConfigurations.x1carbon = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          #! lix
          lix-module.nixosModules.default
          nixos-hardware.nixosModules.lenovo-thinkpad-x1-10th-gen
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

      nixosConfigurations.raspi3bp = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-3
          ./hosts/raspi3bp
          home-manager.nixosModules.home-manager
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

      nixosConfigurations.diskoTest = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/diskoTest
        ];
      };

      homeConfigurations.kazuki = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
          host = "standalone";
        };
        # Specify your home configuration module here, for example,
        # the path to your home.nix
        modules = [
          ./users/kazuki/home.nix
        ];
      };
    };
}
