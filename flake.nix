{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, ... }:
    let
      system = "x86_64-linux"; # Check flake-utils: https://github.com/numtide/flake-utils
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          allowUnfreePredicate = (_ : true);
        };
      };
    in
    {
      nixosConfigurations.x1carbon = nixpkgs.lib.nixosSystem {
        # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
        inherit system;
        modules = [
          ./hosts/x1carbon
          # nixos-hardware.niosModues.lenovo-thinkpad-x1-10th-gen
        ];
      };

      homeConfigurations.kazuki = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        # Specify your home configuration module here, for example,
        # the path to your home.nix
        modules = [ ./users/kazuki/home.nix ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
