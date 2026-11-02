{ pkgs, ... }:

{
  imports = [
    ./keyring-wrapper.nix
  ];

  # Let pam_gnome_keyring unlock the login keyring with the password typed at
  # SSH login. NixOS only configures this for the `login` PAM service by
  # default.
  security.pam.services.sshd.enableGnomeKeyring = true;

  # Require public key authentication followed by the account password. PAM
  # passes the password to pam_gnome_keyring, which unlocks the login keyring.
  services.openssh.settings = {
    AuthenticationMethods = "publickey,password";
    PasswordAuthentication = true;
  };

  # gcr-ssh-agent creates its socket in the systemd user runtime directory.
  # Export it for login shells, but keep the value supplied by agent
  # forwarding when one is present.
  environment.extraInit = ''
    if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
      if [ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
      fi
    fi
  '';

  # secret-tool is useful for inspecting or repairing the login keyring.
  environment.systemPackages = [ pkgs.libsecret ];
}
