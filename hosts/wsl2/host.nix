# wsl2 host module (Dendritic pattern).
#
# Sets myModule.* selector values + host identity. Values reproduce wsl2's
# previous behaviour. WSL2 is a headless/GUI-less environment.
{ lib, ... }:

{
  myModule = {
    machine = "desktop"; # WSL2 on a desktop; not an SBC, so cockpit etc. are fine.

    desktop = {
      compositor = "none";
      displayManager = "none";
      lockscreen = "none";
      components = [ ];
    };

    keyring = "none";
    location = false;
    tailscale = true; # was active on wsl2.

    shell.zshUserNameColor = "green"; # moved from home_wsl.nix myOps.

    # sound/battery derived off (compositor none, not laptop). cockpit derived on
    # (machine != sbc) — matches prior behaviour.

    home = {
      compositor = "none";
      desktopComponents = [ ];
      terminals = [ ];
      editors = [ ]; # wsl2 home pulls editors via its own chain, not the selector.
      screenshots = [ ];
      obsidian = false;
      chromium = false;
    };
  };

  # --- host identity (from hosts/wsl2/default.nix) ---
  wsl.enable = true;
  wsl.defaultUser = "kazuki";
  system.stateVersion = "24.05";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
