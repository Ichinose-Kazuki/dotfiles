{ lib, ... }:
let
  inherit (import ./disko-partitions.nix { inherit lib; }) firmwarePartition espPartition;
in
{
  disko.devices = {
    disk.sdcard = {
      type = "disk";
      # U-Boot on the Pi 5 can only load from the SD slot (no USB/PCIe/RP1
      # support yet), so the firmware and ESP partitions it needs to find must
      # live here rather than on NVMe. They are labelled distinctly from the
      # NVMe partitions that will eventually take over /boot (see
      # disko-nvme.nix), because the generated fstab finds partitions by label
      # and duplicate labels would be ambiguous.
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          firmware = firmwarePartition {
            label = "FIRMWARE-SD";
            content.mountpoint = "/boot/firmware";
          };

          esp = espPartition {
            label = "BOOT-SD";
            content.mountpoint = "/boot";
          };
        };
      };
    };
  };
}
