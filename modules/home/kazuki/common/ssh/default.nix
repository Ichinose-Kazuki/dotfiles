{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  isMH2505 = !lib.hasAttrByPath [ "programs" "ssh" "enableDefaultConfig" ] options;
in
{
  programs.ssh =
    if isMH2505 then
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
          forwardAgent = false;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
        };
      }
    else
      {
        enable = true;
        includes = [ "conf.d/*" ];
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
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
