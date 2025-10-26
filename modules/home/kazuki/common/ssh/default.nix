{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  isHM2505 = !lib.hasAttrByPath [ "programs" "ssh" "enableDefaultConfig" ] options;
in
{
  programs.ssh =
    if isHM2505 then
      {
        enable = true;
        includes = [ "conf.d/*" ];
        addKeysToAgent = "confirm";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        matchBlocks."*" = {
          forwardAgent = true;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
        };
      }
    else # x1carbon, tsuyoServer
      {
        enable = true;
        includes = [ "conf.d/*" ];
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = true;
          addKeysToAgent = "confirm";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
        };
      };
}
