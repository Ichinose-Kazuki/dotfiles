{ config, lib, ... }:

{
  config = lib.mkIf config.myModule.hardware.docker {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };
    # virtualisation.docker.storageDriver = "btrfs";
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
    virtualisation.oci-containers = {
      backend = "docker";
    };
  };
}
