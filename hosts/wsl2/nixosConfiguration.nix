inputs@{
  home-manager,
  nixos-wsl,
  nixpkgs,
  import-tree,
  ...
}:

nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
  };
  modules = [
    (nixos-wsl.outPath + "/modules")
    inputs.nix-index-database.nixosModules.nix-index
    ../../modules/options/my-module.nix
    ../../modules/options/my-module-derived.nix
    ./host.nix
    # Auto-import the NixOS modules relevant to wsl2 (common + wsl2-specific).
    (import-tree [
      ../../modules/nixos/common
      ../../modules/nixos/wsl2
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
          ../../modules/home/kazuki/wsl2
        ])
      ];
      home-manager.users.kazuki = import ../../users/kazuki/home_wsl.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        host = "wsl2";
      };
    }
  ];
}
