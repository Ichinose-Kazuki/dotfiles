{ ... }:

{
  imports = [
    ../editor
  ];

  myOps.zshUserNameColor = "cyan";

  # Preload keys into gcr-ssh-agent before interactive SSH and remember their
  # passphrases in the login keyring.
  programs.zsh.initContent = ''
    alias ssh='ssh-keyring'
  '';

  # Git invokes ssh outside the interactive shell, so point it at the wrapper
  # directly.
  programs.git.settings.core.sshCommand = "ssh-keyring";
}
