# Partition definitions shared by the SD-card and NVMe disko configurations.
# The same physical layout description is used in two roles: on the SD card it
# carries the boot loader U-Boot reads today, and on NVMe it reserves the
# future /boot layout (see disko-nvme.nix). Each caller supplies its own label
# and mountpoint.
{ lib }:
let
  firmwarePartition = lib.recursiveUpdate {
    priority = 1;

    type = "0700"; # Microsoft basic data
    attributes = [
      0 # Required Partition
    ];

    size = "1024M";
    content = {
      type = "filesystem";
      format = "vfat";
      mountOptions = [
        "noatime"
        "noauto"
        "x-systemd.automount"
      ];
    };
  };

  espPartition = lib.recursiveUpdate {
    type = "EF00"; # EFI System Partition (ESP)
    attributes = [
      2 # Legacy BIOS Bootable, for U-Boot to find extlinux config
    ];

    size = "1024M";
    content = {
      type = "filesystem";
      format = "vfat";
      mountOptions = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "umask=0077"
      ];
    };
  };
in
{
  inherit firmwarePartition espPartition;
}
