hasCredentials:
inputs@{
  home-manager,
  niri,
  nixos-hardware,
  nixpkgs,
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
      # home-manager の入力メソッド機能が GTK2 用の immodule キャッシュを
      # 同梱しているため、broken 扱いになった GTK2 を評価できるようにする。
      # home-manager が GTK2 への依存を落としたら削除する。
      problems.handlers."gtk+".broken = "warn";
    };
  };
in
nixpkgs.lib.nixosSystem {
  # Note that you cannot put arbitrary configuration here: the configuration must be placed in the files loaded via modules
  inherit pkgs;
  specialArgs = {
    inherit hasCredentials inputs system;
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
      home-manager.users.kazuki = import ../../users/kazuki/home_x1carbon.nix;
      home-manager.extraSpecialArgs = {
        inherit inputs system;
        host = "x1carbon";
      };
    }
    niri.nixosModules.niri
  ];
}
