# tsuyoServer host module (Dendritic pattern).
#
# Sets myModule.* selector values. Host identity (boot, networking, WoL,
# binfmt, ...) stays in hosts/tsuyoServer/default.nix for now.
{ ... }:

{
  myModule = {
    hostName = "tsuyoServer";
    machine = "server";

    desktop = {
      compositor = "none";
      displayManager = "none";
      lockscreen = "none";
      # gvfs (files) was pulled in for GoPro file access.
      components = [ "files" ];
    };

    keyring = "none";
    location = false;
    tailscale = false;

    # Server-specific tooling (previously imported directly).
    devtool = true;
    gopro = true;

    shell.zshUserNameColor = "212"; # cherry blossom (from home module).

    hardware = {
      docker = true;
    };

    home = {
      compositor = "none";
      desktopComponents = [ ];
      terminals = [ ];
      editors = [
        "nvim"
        "vim"
      ];
      screenshots = [ ];
      obsidian = false;
      chromium = false;
    };
  };
}
