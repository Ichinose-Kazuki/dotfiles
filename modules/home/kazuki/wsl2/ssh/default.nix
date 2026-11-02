{ ... }:

{
  # Use OpenSSH which is installed in Windows.
  # Built-in OpenSSH has limited features.
  # Install fully functional OpenSSH with `winget install Microsoft.OpenSSH.Beta `
  programs.git.settings.core.sshCommand = "/mnt/c/Program\\ Files/OpenSSH/ssh.exe";
  home.shellAliases = {
    ssh = "/mnt/c/Program\\ Files/OpenSSH/ssh.exe";
    ssh-add = "/mnt/c/Program\\ Files/OpenSSH/ssh-add.exe";
  };
}
