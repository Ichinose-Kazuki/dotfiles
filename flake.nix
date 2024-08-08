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
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
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

      nixosConfigurations.x1carbon = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        specialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/x1carbon
          # nixos-hardware.niosModues.lenovo-thinkpad-x1-10th-gen
          # ! Not needed is using standalone home-manager.
          # ! Import standalone settings
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
          # }
        ];
      };

      homeConfigurations.kazuki = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit inputs;
        };
        # Specify your home configuration module here, for example,
        # the path to your home.nix
        modules = [
          ./users/kazuki/home.nix
        ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
