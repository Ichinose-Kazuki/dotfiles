{ ... }:

{
  # Use openSSH which is installed in Windows.
  programs.git.extraConfig.core.sshCommand = "ssh.exe";
  home.shellAliases = {
    ssh = "ssh.exe";
    ssh-add = "ssh-add.exe";
  };
}
