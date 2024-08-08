# dotfiles

## Important commands
- sudo nixos-rebuild switch --flake .#x1carbon
- home-manager switch --flake .#kazuki
- nix-collect-garbage -d [--delete-older-than 7d]
- nix flake update [--commit-lock-file]
  - Only updates the lock file.
  - Everything in specified flake inputs will be downloaded.
  - Run rebuild and home-manager switch again.
- nix store optimise
  - Remove duplicate files in storepaths.

## nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o nix-install.sh

## home-manager
- home-manager is a flake, thus
    `nix run home-manager -- init`
- home-manager options: https://mynixos.com/home-manager/options
    - programs
    - services

## Private files
- https://github.com/ryantm/agenix
- https://github.com/Mic92/sops-nix
- Private repo
    ssh+git://github.com/Icinose-Kazuki/...
    into flake inputs

