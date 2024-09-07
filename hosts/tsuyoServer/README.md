# Tsuyoi Home Server

## Install
- `sudo su`
- Run diskoScript.
    `bash $(nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths --refresh "github:Ichinose-Kazuki/dotfiles#nixosConfigurations.tsuyoServer.config.system.build.diskoScript")`
- Install NixOS.
    `nixos-install --no-root-passwd --flake "github:Ichinose-Kazuki/dotfiles#tsuyoServer"`
    You cannot use --refresh here. If you need a new version of the flake, `git clone` the repo.
