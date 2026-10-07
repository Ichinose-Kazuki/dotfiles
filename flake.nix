{
  description = "A very basic flake";

  nixConfig = {
    connect-timeout = 5;
    extra-substituters = [
      "https://ags.cachix.org"
      "https://nix-community.cachix.org"
      "https://noctalia.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ags.cachix.org-1:naAvMrz0CuYqeyGNyLgE010iUiuf/qx6kYrUv3NwAJ8="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      flake-utils,
      ...
    }:

    {
      # Details: https://nixos.wiki/wiki/Flakes
      nixosModules = {
        common = ./modules/nixos/common;
        rpi5 = ./modules/nixos/rpi5;
        tsuyoServer = ./modules/nixos/tsuyoServer;
        wsl2 = ./modules/nixos/wsl2;
        x1carbon = ./modules/nixos/x1carbon;
      };
      homeManagerModules.kazuki = {
        common = ./modules/home/kazuki/common;
        rpi5 = ./modules/home/kazuki/rpi5;
        tsuyoServer = ./modules/home/kazuki/tsuyoServer;
        wsl2 = ./modules/home/kazuki/wsl2;
        x1carbon = ./modules/home/kazuki/x1carbon;
      };

      nixosConfigurations = import ./hosts inputs;

    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = (_: true);
          };
        };
      in
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
      }
    );

  # Run `nix flake metadata [this dir]` to know which "follows" need to be added.
  inputs = {
    agent-sandbox = {
      url = "git+ssh://git@github.com/Ichinose-Kazuki/agent-sandbox.git";
    };
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
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    # Vendor (raspberrypi/linux) kernel/firmware for the Pi 5, with a binary
    # cache. Its nixpkgs stays pinned to whatever the flake locks; only the
    # kernel and firmware packages are taken from it (see hosts/rpi5).
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell/v4.7.7";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim-config = {
      url = "github:Ichinose-Kazuki/nvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    waydroid-script = {
      url = "github:casualsnek/waydroid_script";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tmux-config = {
      url = "github:Ichinose-Kazuki/tmux-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
