{
  pkgs,
  lib,
  config,
  ...
}:

{
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
    extraConfig = ''
      ClientAliveInterval 60
      ClientAliveCountMax 3
    '';
  };
}
