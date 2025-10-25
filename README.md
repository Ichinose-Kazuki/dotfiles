# dotfiles

## Important commands
- Build the nixosConfiguration
  ```
  sudo nixos-rebuild switch --flake ".#x1carbon" --accept-flake-config
  ```
- Avoid unnecessary queries to binary cache while building
  ```
  sudo nixos-rebuild switch --flake ".#x1carbon" --accept-flake-config --option substitute false
  ```
- For standalone hm
  ```
  home-manager switch --flake ".#kazuki"
  ```
- Garbage-collect nix store
  ```
  nix-collect-garbage -d [--delete-older-than 7d]
  ```
  - Run as sudo to collect system garbages.
  - Run as a normal user to collect garbages in its home directory.
- Update flake.lock
  ```
  nix flake update [--commit-lock-file]
  ```
  - Only updates the lock file.
  - Everything in specified flake inputs will be downloaded.
  - Run rebuild and home-manager switch again.
- Remove duplicate files in storepaths.
  ```
  nix store optimise
  ``` 

## nix
Installation
```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o nix-install.sh
```

## home-manager
- Create initial hm config(?)
  ```
  nix run home-manager -- init
  ```
  - Note that hm is a flake.
- home-manager options: https://mynixos.com/home-manager/options

## Private files
- https://github.com/ryantm/agenix
- https://github.com/Mic92/sops-nix
- Private repo
    ssh+git://github.com/Icinose-Kazuki/...
    into flake inputs


## Install
- Boot a NixOS installer image
- Root privilege 
  ```
  sudo su
  ```
- Evaluate diskoScript once.
  ```
  nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths --refresh github:Ichinose-Kazuki/dotfiles#nixosConfigurations.x1carbon.config.system.build.diskoScript > /dev/null
  ```
- Fetch files from customDiskoScript directory.
  ```
  curl -o diskoScript https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/diskoScript
  ```
     -  Uses custom disk-deactivate script.
     -  Skips formatting regardless of results of TYPE checks for /dev/nvme0n1p3 and /dev/nvme0n1p5. They are not filesystems (probably), so they don't have TYPE. Does the same for  /dev/nvme0n1p4 just in case.
  ```
  curl -o disk-deactivate https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/disk-deactivate
  ```
  ```
  curl -o disk-deactivate.jq https://raw.githubusercontent.com/Ichinose-Kazuki/dotfiles/main/customDiskoScript/disk-deactivate.jq
  ```
     -  Skips wipefs on partitions from /dev/nvme0n1p3 to /dev/nvme0n1p5.
- Run diskoScript.
  ```
  bash diskoScript
  ```
- Install the nixosConfiguration.
  ```
  nixos-install --no-root-passwd --flake github:Ichinose-Kazuki/dotfiles#x1carbon
  ```
- Need to change disk-by-uuid -> Use disko

## nix repl
- Build check
  ```
  nixosConfigurations.*.config.system.build.toplevel
  ```
- nixpkgs options
  ```
  nixosConfigurations.*.config
  ```
- homeManager options
  ```
  nixosConfigurations.*.config.home-manager.users.*
  ```
