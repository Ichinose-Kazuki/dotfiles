{
  pkgs,
  lib,
  config,
  ...
}:

{
  # configures dbus, xdg portal and pam at login
  services.gnome.gnome-keyring.enable = true;

  # managing encryption keys and passwords in the GNOME Keyring.
  # configures sshaskpass to use seahorse.
  programs.seahorse = {
    enable = true;
  };
}
