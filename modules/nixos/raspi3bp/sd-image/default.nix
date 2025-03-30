# This module was lifted from nixpkgs installer code. It is modified
# so as to not import all-hardware. The goal here is to write the
# nixos image for a raspberry pi to an sd-card in a way so that we can
# pop it in and go. We don't need to support many possible hardware
# targets since we know we are targeting raspberry pi products.

# This module creates a bootable SD card image containing the given NixOS
# configuration. The generated image is MBR partitioned, with a FAT
# /boot/firmware partition, and ext4 root partition. The generated image
# is sized to fit its contents, and a boot script automatically resizes
# the root partition to fit the device on the first boot.
#
# The firmware partition is built with expectation to hold the Raspberry
# Pi firmware and bootloader, and be removed and replaced with a firmware
# build for the target SoC for other board families.
#
# The derivation for the SD image will be placed in
# config.system.build.sdImage

{
  modulesPath,
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  rootfsImage = pkgs.callPackage "${modulesPath}/../lib/make-ext4-fs.nix" (
    {
      inherit (config.sdImage) storePaths;
      compressImage = true;
      populateImageCommands = config.sdImage.populateRootCommands;
      volumeLabel = "NIXOS_SD";
    }
    // optionalAttrs (config.sdImage.rootPartitionUUID != null) {
      uuid = config.sdImage.rootPartitionUUID;
    }
  );
in
{
  imports = [ ];

  config = {
    fileSystems = {
      "/boot/firmware" = {
        device = "/dev/disk/by-label/${config.sdImage.firmwarePartitionName}";
        fsType = "vfat";
      };
    };

    sdImage.storePaths = [ config.system.build.toplevel ];

    system.build.mySdImage = pkgs.callPackage (
      {
        stdenv,
        dosfstools,
        e2fsprogs,
        mtools,
        libfaketime,
        util-linux,
        zstd,
      }:
      stdenv.mkDerivation {
        name = config.sdImage.imageName;

        nativeBuildInputs = [
          dosfstools
          e2fsprogs
          mtools
          libfaketime
          util-linux
          zstd
        ];

        inherit (config.sdImage) compressImage;

        buildCommand = ''
          mkdir -p $out/nix-support $out/sd-image
          export img=$out/sd-image/${config.sdImage.imageName}

          echo "${pkgs.stdenv.buildPlatform.system}" > $out/nix-support/system
          if test -n "$compressImage"; then
            echo "file sd-image $img.zst" >> $out/nix-support/hydra-build-products
          else
            echo "file sd-image $img" >> $out/nix-support/hydra-build-products
          fi

          echo "Decompressing rootfs image"
          zstd -d --no-progress "${rootfsImage}" -o ./root-fs.img

          # Gap in front of the first partition, in MiB
          gap=${toString config.sdImage.firmwarePartitionOffset}

          # Create the image file sized to fit /boot/firmware and /, plus slack for the gap.
          rootSizeBlocks=$(du -B 512 --apparent-size ./root-fs.img | awk '{ print $1 }')
          firmwareSizeBlocks=$((${toString config.sdImage.firmwareSize} * 1024 * 1024 / 512))
          imageSize=$((rootSizeBlocks * 512 + firmwareSizeBlocks * 512 + gap * 1024 * 1024))
          truncate -s $imageSize $img

          # type=b is 'W95 FAT32', type=83 is 'Linux'.
          # The "bootable" partition is where u-boot will look file for the bootloader
          # information (dtbs, extlinux.conf file).
          sfdisk $img <<EOF
              label: dos
              label-id: ${config.sdImage.firmwarePartitionID}

              start=''${gap}M, size=$firmwareSizeBlocks, type=b
              start=$((gap + ${toString config.sdImage.firmwareSize}))M, type=83, bootable
          EOF

          # Copy the rootfs into the SD image
          eval $(partx $img -o START,SECTORS --nr 2 --pairs)
          dd conv=notrunc if=./root-fs.img of=$img seek=$START count=$SECTORS

          # Create a FAT32 /boot/firmware partition of suitable size into firmware_part.img
          eval $(partx $img -o START,SECTORS --nr 1 --pairs)
          truncate -s $((SECTORS * 512)) firmware_part.img
          faketime "1970-01-01 00:00:00" mkfs.vfat -i ${config.sdImage.firmwarePartitionID} -n ${config.sdImage.firmwarePartitionName} firmware_part.img

          # Populate the files intended for /boot/firmware
          mkdir firmware
          ${config.sdImage.populateFirmwareCommands}

          # Copy the populated /boot/firmware into the SD image
          (cd firmware; mcopy -psvm -i ../firmware_part.img ./* ::)
          # Verify the FAT partition before copying it.
          fsck.vfat -vn firmware_part.img
          dd conv=notrunc if=firmware_part.img of=$img seek=$START count=$SECTORS

          ${config.sdImage.postBuildCommands}

          if test -n "$compressImage"; then
              zstd -T$NIX_BUILD_CORES --rm $img
          fi
        '';
      }
    ) { };

    # nix-path-registration is a file created by make-ext4-fs.nix
    # https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/make-ext4-fs.nix
    # Builds an ext4 image containing a populated /nix/store with the closure
    # of store paths passed in the storePaths parameter, in addition to the
    # contents of a directory that can be populated with commands. The
    # generated image is sized to only fit its contents, with the expectation
    # that a script resizes the filesystem at boot time.
    # Single partition is probably a limitation of make-ext4-fs.nix. -> lvm?
    boot.postBootCommands = lib.mkIf config.sdImage.expandOnBoot ''
      # On the first boot do some maintenance tasks
      if [ -f /nix-path-registration ]; then
        set -euo pipefail
        set -x
        # Figure out device names for the boot device and root filesystem.
        rootPart=$(${pkgs.util-linux}/bin/findmnt -n -o SOURCE /)
        bootDevice=$(lsblk -npo PKNAME $rootPart)
        partNum=$(lsblk -npo MAJ:MIN $rootPart | ${pkgs.gawk}/bin/awk -F: '{print $2}')

        # Resize the root partition and the filesystem to fit the disk
        echo ",+," | sfdisk -N$partNum --no-reread $bootDevice
        ${pkgs.parted}/bin/partprobe
        ${pkgs.e2fsprogs}/bin/resize2fs $rootPart

        # Register the contents of the initial Nix store
        ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration

        # nixos-rebuild also requires a "system" profile and an /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

        # Prevents this from running on later boots.
        rm -f /nix-path-registration
      fi
    '';
  };
}
