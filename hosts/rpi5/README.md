# Raspberry Pi 5

## Installation
1. Build an installer image from nixos-raspberrypi and burn it to a USB drive (at least 16 GB) using toosl like raspi-imager. 

    You need to enable aarch64 emulation to build.
    ```nix
    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    ```

    ```shell
    # This can take ~10 min (mostly copying files)
    nix build 'github:nvmd/nixos-raspberrypi#installerImages.rpi5' --accept-flake-config
    ```
2. Boot and ssh to the rpi. The boot process takes a while. After booting up, the root password and ip address are shown in the display.
    ```shell
    ssh root@[ip addr]
    ```
3. Format disks.
    ```shell
    bash $(nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths --accept-flake-config --refresh github:Ichinose-Kazuki/dotfiles#nixosConfigurations.rpi5.config.system.build.diskoScript)
    ```
4. Install.
    ```shell
    nixos-install --no-root-passwd --flake github:Ichinose-Kazuki/dotfiles#rpi5
    ```
