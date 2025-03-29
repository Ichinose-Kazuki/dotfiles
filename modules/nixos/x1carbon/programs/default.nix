{ inputs, pkgs, ... }:

{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wol # Wake-on-LAN
  ];
  programs.firefox.enable = true;
}
