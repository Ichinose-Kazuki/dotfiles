{ lib, ... }:
let
  inherit (import ./disko-partitions.nix { inherit lib; }) firmwarePartition espPartition;
in
{
  disko.devices = {
    disk.nvme0 = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          # U-Boot cannot read NVMe yet, so /boot currently lives on the SD card
          # (see disko-sdcard.nix). These partitions keep the future /boot
          # layout on the NVMe without mounting it, so that once U-Boot can boot
          # from NVMe, /boot can be moved back here from the SD card.
          firmware = firmwarePartition {
            label = "FIRMWARE";
          };

          esp = espPartition {
            label = "ESP";
          };

          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
