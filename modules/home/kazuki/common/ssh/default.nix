{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  # Three home-manager SSH API generations (detected by capability, not host):
  # 1. Old HM (no enableDefaultConfig): top-level addKeysToAgent/controlMaster
  #    + matchBlocks. No current host uses this, kept as a defensive fallback.
  # 2. HM 25.05 (main home-manager): has enableDefaultConfig + settings."*".
  # 3. HM 25.11 (nixos-raspberrypi-home-manager, rpi5): has enableDefaultConfig
  #    but no settings, uses matchBlocks only.
  hasEnableDefaultConfig = lib.hasAttrByPath [ "programs" "ssh" "enableDefaultConfig" ] options;
  hasSshSettings = lib.hasAttrByPath [ "programs" "ssh" "settings" ] options;

  # Legacy check name kept for clarity: true = old HM without enableDefaultConfig
  isHM2505 = !hasEnableDefaultConfig;
in
{
  programs.ssh =
    if isHM2505 then
      # HM 24.05 old API: top-level options + matchBlocks
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
    else if hasSshSettings then
      # HM 25.05 new API: settings."*" block (matchBlocks is deprecated alias)
      {
        enable = true;
        includes = [ "conf.d/*" ];
        enableDefaultConfig = false;
        settings."*" = {
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
      }
    else
      # HM 25.11 (nixos-raspberrypi): has enableDefaultConfig but no settings;
      # uses matchBlocks like old API, but needs enableDefaultConfig set
      {
        enable = true;
        includes = [ "conf.d/*" ];
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = true;
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
        };
        extraConfig = ''
          AddKeysToAgent confirm
          HashKnownHosts no
          UserKnownHostsFile ~/.ssh/known_hosts
          ControlMaster no
          ControlPath ~/.ssh/master-%r@%n:%p
          ControlPersist no
        '';
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
