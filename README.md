# dotfiles
- sudo nixos-rebuild switch --flake .#x1carbon
- home-manager switch --flake .#kazuki
- nix-collect-garbage -d [--delete-older-than 7d]
- nix flake update [--commit-lock-file]
  - Only updates the lock file.
  - Everything in specified flake inputs will be downloaded.
  - Run rebuild and home-manager switch again.
- nix store optimise
  - Remove duplicate files in storepaths.
