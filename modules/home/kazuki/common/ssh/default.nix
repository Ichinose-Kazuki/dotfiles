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
    # x1carbon, tsuyoServer
    else
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

  # workaround for .ssh/config permission problem in vscode-fhs
  # https://github.com/nix-community/home-manager/issues/322#issuecomment-411904993
  home.file.".ssh/config".enable = false;
  home.activation.copySshConfig =
    let
      cfgFile = pkgs.writeText "ssh-config" config.home.file.".ssh/config".text;
    in
    lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -m600 -D ${cfgFile} $HOME/.ssh/config
    '';
}
