inputs@{
  home-manager,
  nixos-wsl,
  nixpkgs,
  ...
}:

nixpkgs.lib.nixosSystem {
  # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
  specialArgs = {
    inherit inputs;
  };
  modules = [
    ../wsl2
    (nixos-wsl.outPath + "/modules")
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.kazuki = import ../../users/kazuki/home_wsl.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        host = "wsl2";
      };
    }
  ];
}
