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
    # Auto-import all NixOS modules relevant to x1carbon. Other hosts' module
    # dirs are intentionally excluded; rollout uses per-host scoped roots.
    (import-tree [
      ../../modules/nixos/common
      ../../modules/nixos/x1carbon
      ../../modules/nixos/keyboard
      ../../modules/nixos/keyring
      ../../modules/nixos/files
      ../../modules/nixos/system-components
    ])
    niri.nixosModules.niri
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.sharedModules = [
        ../../modules/options/my-module.nix
        ../../modules/options/my-module-derived.nix
        (import-tree [
          ../../modules/home/kazuki/common
          ../../modules/home/kazuki/x1carbon
          ../../modules/home/kazuki/desktop
          ../../modules/home/kazuki/desktop-utils
          ../../modules/home/kazuki/dev-utils
          ../../modules/home/kazuki/editor
          ../../modules/home/kazuki/entertainment
          ../../modules/home/kazuki/input-method
          ../../modules/home/kazuki/keyring
        ])
      ];
      home-manager.users.kazuki = import ../../users/kazuki/home_x1carbon.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs system;
        host = "x1carbon";
      };
    }
  ];
}
