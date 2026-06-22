inputs@{
  home-manager,
  niri,
  nixos-hardware,
  nixpkgs,
  import-tree,
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
  inherit pkgs;
  specialArgs = {
    inherit inputs system;
  };
  modules = [
    nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    inputs.nix-index-database.nixosModules.nix-index
    inputs.disko.nixosModules.disko
    ../../modules/options/my-module.nix
    ../../modules/options/my-module-derived.nix
    ./host.nix
    ./hardware-configuration.nix
    ./disko.nix
    # Whole-tree import: every host imports all NixOS modules. Host-specific
    # ones guard on myModule.hostName; feature modules on their myModule selector.
    (import-tree ../../modules/nixos)
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.sharedModules = [
        ../../modules/options/my-module.nix
        ../../modules/options/my-module-derived.nix
        (import-tree ../../modules/home/kazuki)
      ];
      home-manager.users.kazuki = import ../../users/kazuki/home_x1carbon.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs system;
        host = "x1carbon";
      };
    }
  ];
}
