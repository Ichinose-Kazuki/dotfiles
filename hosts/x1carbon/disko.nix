{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "260M";
              _index = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            msReserved = {
              type = "0C01";
              size = "16M";
              _index = 2;
              content = {
                type = "filesystem";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p2".
              };
            };
            winBasicData = {
              type = "0700";
              size = "200G";
              _index = 3;
              content = {
                type = "filesystem";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p3".
              };
            };
            winRecovery = {
              type = "2700";
              size = "2G";
              _index = 4;
              content = {
                type = "filesystem";
                # To be ignored in disk-deactivate.jq. "/dev/nvme0n1p4".
              };
            };
            luksLvm = {
              size = "100%";
              _index = 5;
              content = {
                type = "luks";
                name = "crypted";
                extraOpenArgs = [ ];
                settings = {
                  # if you want to use the key for interactive login be sure there is no trailing newline
                  # for example use `echo -n "password" > /tmp/secret.key`
                  keyFile = "/tmp/secret.key";
                  allowDiscards = true;
                };
                additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
          home = {
            size = "10M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/home";
            };
          };
          raw = {
            size = "10M";
          };
        };
      };
    };
  };
}
