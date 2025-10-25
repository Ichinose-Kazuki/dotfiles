{
  description = "A very basic flake";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://ags.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }:

    {
      # Details: https://nixos.wiki/wiki/Flakes
      nixosModules = {
        common = ./modules/nixos/common;
        raspi3bp = ./modules/nixos/raspi3bp;
        tsuyoServer = ./modules/nixos/tsuyoServer;
        wsl2 = ./modules/nixos/wsl2;
        x1carbon = ./modules/nixos/x1carbon;
      };
      homeManagerModules.kazuki = {
        common = ./modules/home/kazuki/common;
        raspi3bp = ./modules/home/kazuki/raspi3bp;
        tsuyoServer = ./modules/home/kazuki/tsuyoServer;
        wsl2 = ./modules/home/kazuki/wsl2;
        x1carbon = ./modules/home/kazuki/x1carbon;
      };

      nixosConfigurations = import ./hosts inputs;

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
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
