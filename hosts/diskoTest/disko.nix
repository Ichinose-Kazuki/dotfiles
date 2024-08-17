{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "250M";
              _index = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            protect = {
              type = "8300";
              size = "10M";
              _index = 2;
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/protect";
              };
            };
            root = {
              type = "8300";
              size = "100%";
              _index = 3;
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
  };
}
