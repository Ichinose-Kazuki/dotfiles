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
          # The Raspberry Pi firmware loads the kernel, initrd and device trees
          # from the firmware partition itself, so it holds the boot code,
          # config.txt, device trees and the NixOS kernels. It lives on NVMe,
          # which the firmware can boot from.
          firmware = firmwarePartition {
            label = "FIRMWARE";
            content.mountpoint = "/boot/firmware";
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
