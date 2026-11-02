{ config, pkgs, lib, ... }:

let
  sshAddKeyring = pkgs.writeShellApplication {
    name = "ssh-add-keyring";
    runtimeInputs = with pkgs; [
      coreutils
      libsecret
      openssh
    ];
    text = builtins.readFile ./ssh-add-keyring.sh;
  };

  sshKeyring = pkgs.writeShellApplication {
    name = "ssh-keyring";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      libsecret
    ];
    runtimeEnv = {
      REAL_SSH = lib.getExe config.programs.ssh.package;
      SSH_ADD_KEYRING = "${sshAddKeyring}/bin/ssh-add-keyring";
    };
    text = builtins.readFile ./ssh-keyring.sh;
  };
in
{
  environment.systemPackages = [
    sshAddKeyring
    sshKeyring
  ];
}
