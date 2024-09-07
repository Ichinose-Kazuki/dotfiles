# Raspberry Pi 3B+

## Building an sd-card image
- In `flake.nix`, add `cross-compile` in the modules in your current system, if it's not "aarch64-linux" system.
- Run `sudo nix build ".#nixosConfigurations.raspi3bp.config.system.build.sdImage"`.
    - Run as root to enable binary cache.
