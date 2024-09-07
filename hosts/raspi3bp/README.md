# Raspberry Pi 3B+

## Install

### Build a SD card image
- On a powerful server (with either native or qemu aarch64-linux support), run:
    `sudo nix build ".#nixosConfigurations.raspi3bp.config.system.build.sdImage"`.
    - Running this on Raspberry Pi will take forever.

### Write to SD card.
- Fetch the image.
- Use imager to write the image to SD card.

## Update
- 
