inputs@{
  home-manager,
  nixos-hardware,
  nixpkgs,
  plasma-manager,
  ...
}:

let
  system = "x86_64-linux";
  overlays = [
    inputs.efi-power.overlays.default
  ];
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
    inherit inputs system;
  };
  modules = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    ../x1carbon
    # ! Not needed if using standalone home-manager.
    # ! Import standalone settings
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      # home-manager.sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
      home-manager.users.kazuki = import ../../users/kazuki/home_x1carbon.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs system;
        host = "x1carbon";
      };
    }
  ];
}
