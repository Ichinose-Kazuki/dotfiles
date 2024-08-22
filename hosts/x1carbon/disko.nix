{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            p1_ESP = { # Partitions are sorted in alphabetical order?
              type = "EF00";
              size = "260M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            p2_msReserved = {
              type = "0C01";
              size = "16M";
              content = {
                type = "filesystem";
                format = "none";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p2".
              };
            };
            p3_msBasicData = {
              type = "0700";
              size = "200G";
              content = {
                type = "filesystem";
                format = "none";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p3".
              };
            };
            p4_winRecovery = {
              type = "2700";
              size = "2G";
              content = {
                type = "filesystem";
                format = "none";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p4".
              };
            };
            p5_luksLvm = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ ];
                settings = {
                  # if you want to use the key for interactive login be sure there is no trailing newline
                  # for example use `echo -n "password" > /tmp/secret.key`
                  keyFile = "/tmp/secret.key";
                  # Enable SSD TRIM command
                  # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "MyVolGroup";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      MyVolGroup = {
        type = "lvm_vg";
        lvs = {
          root = let
              # In the current btrfs implementation, all subvolumes share the same options.
              rootBtrfsOptions = [ "compress=zstd:8" "noatime" "enospc_debug" ];
            in
            {
            size = "100G";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              # Subvolumes must set a mountpoint in order to be mounted,
              # unless their parent is mounted
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = rootBtrfsOptions;
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = rootBtrfsOptions;
                };
              };
            };
          };
          home = let
              # In the current btrfs implementation, all subvolumes share the same options.
              # LZO is better on nvme-ssd: https://gist.github.com/braindevices/fde49c6a8f6b9aaf563fb977562aafec
              homeBtrfsOptions = [ "compress=lzo" "noatime" "enospc_debug" "usebackuproot" ];
            in
            {
            size = "150G";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = homeBtrfsOptions;
                };
                # Run `btrfs subvolume snapshot /home /snapshots/home/xxxx-xx-xx */` to create a snapshot.
                "/snapshots" = {
                  mountpoint = "/snapshots";
                  mountOptions = homeBtrfsOptions;
                };
              };
            };
          };
          encryptedSwap = {
              size = "100%";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100; # prefer to encrypt as long as we have space for it
              };
            };
        };
      };
    };
  };
}
