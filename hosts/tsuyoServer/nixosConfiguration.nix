inputs@{
  home-manager,
  nixpkgs,
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
  # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
  inherit pkgs;
  specialArgs = {
    inherit inputs;
  };
  modules = [
    ../tsuyoServer
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.kazuki = import ../../users/kazuki/home_tsuyoServer.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        host = "tsuyoServer";
      };
    }
  ];
}
