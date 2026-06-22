{
  pkgs,
  lib,
  config,
  ...
}:

{
  config = lib.mkIf (config.myModule.hostName == "x1carbon") {
    # Client side
    programs.ssh = {
      startAgent = lib.mkIf (!config.services.gnome.gcr-ssh-agent.enable) true;
      enableAskPassword = true;
    };

    # Server side
    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      startWhenNeeded = true;
    };
  };
}
