{
  virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.oci-containers = {
    backend = "docker";
  };
}
