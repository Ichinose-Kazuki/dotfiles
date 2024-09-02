# dotfiles

## Important commands
- sudo nixos-rebuild switch --flake ".#x1carbon"
- home-manager switch --flake ".#kazuki"
- nix-collect-garbage -d [--delete-older-than 7d]
  - Run as sudo to collect system garbages.
  - Run as a normal user to collect garbages in its home directory.
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


## Install
- `sudo su`
- Evaluate diskoScript once.
  `nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths --refresh github:Ichinose-Kazuki/dotfiles#nixosConfigurations.x1carbon.config.system.build.diskoScript > /dev/null`
- Fetch files from customDiskoScript directory.
  -  `curl -o diskoScript https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/diskoScript`
     -  Uses custom disk-deactivate script.
     -  Skips formatting regardless of results of TYPE check on /dev/nvme0n1p2 and /dev/nvme0n1p4. They are not filesystems (probably), so they don't have TYPE. Do the same on  /dev/nvme0n1p3 just in case.
  -  `curl -o disk-deactivate https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/disk-deactivate`
  -  `curl -o disk-deactivate.jq https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/disk-deactivate.jq`
     -  Skips wipefs on partitions from /dev/nvme0n1p1 to /dev/nvme0n1p4.
- Run diskoScript.
  `bash diskoScript`
- `nixos-install --no-root-passwd --flake github:Ichinose-Kazuki/dotfiles#x1carbon`
- Need to change disk-by-uuid -> Use disko
