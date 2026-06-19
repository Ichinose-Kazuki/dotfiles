inputs@{
  home-manager,
  nixpkgs,
  import-tree,
  ...
}:

let
  system = "x86_64-linux";
  overlays = [ inputs.efi-power.overlays.default ];
  pkgs = import nixpkgs {
    inherit system overlays;
  };
in
nixpkgs.lib.nixosSystem {
  inherit pkgs;
  specialArgs = {
    inherit inputs;
  };
  modules = [
    inputs.nix-index-database.nixosModules.nix-index
    inputs.disko.nixosModules.disko
    ../../modules/options/my-module.nix
    ../../modules/options/my-module-derived.nix
    ./host.nix
    ./hardware-configuration.nix
    ./disko.nix
    ./default.nix
    # Auto-import the NixOS modules relevant to tsuyoServer. The docker module
    # lives under x1carbon/ but is shared; pull just that leaf.
    (import-tree [
      ../../modules/nixos/common
      ../../modules/nixos/tsuyoServer
      ../../modules/nixos/files
      ../../modules/nixos/x1carbon/docker
    ])
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [
        ../../modules/options/my-module.nix
        ../../modules/options/my-module-derived.nix
        (import-tree [
          ../../modules/home/kazuki/common
          ../../modules/home/kazuki/tsuyoServer
          ../../modules/home/kazuki/editor
        ])
      ];
      home-manager.users.kazuki = import ../../users/kazuki/home_tsuyoServer.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        host = "tsuyoServer";
      };
    }
  ];
}
