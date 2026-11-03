{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fim # Framebuffer Image Viewer
    wol # Wake-on-LAN
  ];
  programs.firefox.enable = true;

  # Manages encryption keys and passwords in the GNOME Keyring, and provides
  # the ssh-askpass helper used by programs.ssh.enableAskPassword.
  programs.seahorse.enable = true;

  # Keep the Bitwarden extension (nngceckbapebfimnlniiiahkandclblb) from
  # running its content scripts on chatgpt.com and its subdomains.
  programs.chromium = {
    enable = true;
    extraOpts.ExtensionSettings."eimadpbcbfnmbkopoojfekhnkhdbieeh".runtime_blocked_hosts = [
      "*://*.chatgpt.com"
    ];
  };
}
