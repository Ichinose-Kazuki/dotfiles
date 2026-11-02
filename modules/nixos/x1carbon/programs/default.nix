{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fim # Framebuffer Image Viewer
    wol # Wake-on-LAN
  ];
  programs.firefox.enable = true;

  # Keep the Bitwarden extension (nngceckbapebfimnlniiiahkandclblb) from
  # running its content scripts on chatgpt.com and its subdomains.
  programs.chromium = {
    enable = true;
    extraOpts.ExtensionSettings."nngceckbapebfimnlniiiahkandclblb".runtime_blocked_hosts = [
      "*://*.chatgpt.com"
    ];
  };
}
