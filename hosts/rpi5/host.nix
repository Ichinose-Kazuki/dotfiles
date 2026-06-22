# rpi5 host module (Dendritic pattern).
#
# SBC host — no compositor, no desktop, tailscale on, nvim+vim editors.
# cockpit and lix are derived OFF for sbc via my-module-derived.nix.
{ ... }:

{
  myModule = {
    hostName = "rpi5";
    machine = "sbc";

    desktop = {
      compositor = "none";
      displayManager = "none";
      lockscreen = "none";
      components = [ ];
    };

    keyring = "none";
    location = false;
    tailscale = true;

    shell.zshUserNameColor = "cyan"; # moved from modules/home/kazuki/rpi5/default.nix

    home = {
      compositor = "none";
      desktopComponents = [ ];
      terminals = [ ];
      editors = [ "nvim" "vim" ]; # rpi5 home DOES import ../editor
      screenshots = [ ];
      obsidian = false;
      chromium = false;
    };
  };
}
