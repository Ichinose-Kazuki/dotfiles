# raspi3bp host module (Dendritic pattern).
#
# SBC host — no compositor, no desktop, tailscale on.
# cockpit and lix are derived OFF for sbc via my-module-derived.nix.
{ ... }:

{
  myModule = {
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

    shell.zshUserNameColor = "cyan"; # moved from modules/home/kazuki/raspi3bp/default.nix

    home = {
      compositor = "none";
      desktopComponents = [ ];
      terminals = [ ];
      editors = [ ]; # raspi3bp home does NOT import ../editor
      screenshots = [ ];
      obsidian = false;
      chromium = false;
    };
  };
}
