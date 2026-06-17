{
  description = "A very basic flake";

  nixConfig = {
    connect-timeout = 5;
    extra-substituters = [
      "https://ags.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
      "https://noctalia.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        { pkgs, ... }:
        {
          # Formatter used in this directory by `nix fmt`.
          formatter = pkgs.nixpkgs-fmt;
          # Does not work with direnv. https://github.com/NixOS/nixfmt/issues/151
          # formatter = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
          # `nix develop`
          devShells.default = pkgs.mkShell {
            buildInputs = [
              # Runtime dependency (e.g., a library the program needs)
            ];
            nativeBuildInputs = with pkgs; [
              nil # lsp language server for nix
              nix-output-monitor # utility to get more info about nix-build (usage: "nom build")
              nixpkgs-fmt
            ];
          };
        };

      flake = {
        # Details: https://nixos.wiki/wiki/Flakes
        nixosModules = {
          common = ./modules/nixos/common;
          raspi3bp = ./modules/nixos/raspi3bp;
          rpi5 = ./modules/nixos/rpi5;
          tsuyoServer = ./modules/nixos/tsuyoServer;
          wsl2 = ./modules/nixos/wsl2;
          x1carbon = ./modules/nixos/x1carbon;
        };
        homeManagerModules.kazuki = {
          common = ./modules/home/kazuki/common;
          raspi3bp = ./modules/home/kazuki/raspi3bp;
          rpi5 = ./modules/home/kazuki/rpi5;
          tsuyoServer = ./modules/home/kazuki/tsuyoServer;
          wsl2 = ./modules/home/kazuki/wsl2;
          x1carbon = ./modules/home/kazuki/x1carbon;
        };

        nixosConfigurations =
          # Other hosts keep their current hosts/<host>/nixosConfiguration.nix
          # definitions; x1carbon is the pilot migrated to the Dendritic layout.
          (import ./hosts inputs)
          // {
            x1carbon =
              let
                system = "x86_64-linux";
                overlays = [
                  inputs.efi-power.overlays.default
                ];
                pkgs = import inputs.nixpkgs {
                  inherit system overlays;
                  config = {
                    allowUnfree = true;
                    allowUnfreePredicate = (_: true);
                  };
                };
              in
              inputs.nixpkgs.lib.nixosSystem {
                inherit pkgs;
                specialArgs = {
                  inherit inputs system;
                };
                modules = [
                  inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
                  inputs.nix-index-database.nixosModules.nix-index
                  inputs.disko.nixosModules.disko
                  ./modules/options/my-module.nix
                  ./modules/options/my-module-derived.nix
                  ./hosts/x1carbon/host.nix
                  ./hosts/x1carbon/hardware-configuration.nix
                  ./hosts/x1carbon/disko.nix
                  # Auto-import all NixOS modules relevant to x1carbon. Other
                  # hosts' module dirs are intentionally excluded for the pilot;
                  # rollout will switch to whole-tree + hostName guards.
                  (inputs.import-tree [
                    ./modules/nixos/common
                    ./modules/nixos/x1carbon
                    ./modules/nixos/keyboard
                    ./modules/nixos/keyring
                    ./modules/nixos/files
                    ./modules/nixos/system-components
                  ])
                  inputs.niri.nixosModules.niri
                  inputs.home-manager.nixosModules.home-manager
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.backupFileExtension = "backup";
                    home-manager.sharedModules = [
                      ./modules/options/my-module.nix
                      ./modules/options/my-module-derived.nix
                      (inputs.import-tree [
                        ./modules/home/kazuki/common
                        ./modules/home/kazuki/x1carbon
                        ./modules/home/kazuki/desktop
                        ./modules/home/kazuki/desktop-utils
                        ./modules/home/kazuki/dev-utils
                        ./modules/home/kazuki/editor
                        ./modules/home/kazuki/entertainment
                        ./modules/home/kazuki/input-method
                        ./modules/home/kazuki/keyring
                      ])
                    ];
                    home-manager.users.kazuki = import ./users/kazuki/home_x1carbon.nix;
                    home-manager.extraSpecialArgs = {
                      inherit inputs system;
                      host = "x1carbon";
                    };
                  }
                ];
              };
          };
      };
    };

  # Run `nix flake metadata [this dir]` to know which "follows" need to be added.
  inputs = {
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    efi-power = {
      url = "github:Ichinose-Kazuki/efi-power";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flameshot.url = "github:flameshot-org/flameshot/v14.0.rc2";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    impermanence.url = "github:nix-community/impermanence";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main"; # main is considered being stable
    nixos-raspberrypi-disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos-raspberrypi-nixpkgs";
    };
    nixos-raspberrypi-home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixos-raspberrypi-nixpkgs";
    };
    nixos-raspberrypi-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixos-raspberrypi-nixpkgs";
    };
    nixos-raspberrypi-nixpkgs.follows = "nixos-raspberrypi/nixpkgs";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-config = {
      url = "github:Ichinose-Kazuki/nvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix?ref=refs/tags/v0.4.1"; # Repo has been archived
    raspi-home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "raspi-nixpkgs";
    };
    raspi-nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "raspi-nixpkgs";
    };
    raspi-nixpkgs.follows = "raspberry-pi-nix/nixpkgs"; # Avoid rebuilding linux kernel
  };
}
