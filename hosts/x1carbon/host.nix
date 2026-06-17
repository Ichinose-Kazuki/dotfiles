# x1carbon host module (Dendritic pattern).
#
# Sets `myModule.*` selector values (schema in modules/options/my-module.nix,
# consumed by guarded leaf modules) plus host identity settings that are
# specific to this machine and not worth turning into modules.
#
# Values are chosen to reproduce x1carbon's previous behaviour exactly.
{
  pkgs,
  inputs,
  ...
}:

{
  myModule = {
    machine = "laptop";

    desktop = {
      compositor = "niri";
      displayManager = "regreet";
      lockscreen = "gtklock";
      components = [
        # NOTE: "wayland-utils" intentionally omitted — modules/nixos/x1carbon/wayland
        # is currently disabled on x1carbon (niri pulls in the wayland tools it needs).
        "files"
        "gpu-recorder"
        "wtfutil"
        "programs"
      ];
    };

    keyring = "gnome-keyring";
    location = true;
    tailscale = true;

    shell.zshUserNameColor = "blue";

    # hardware.sound / hardware.battery are derived (laptop + desktop != none).
    # printing / docker / gaming are not derived, so set them explicitly.
    hardware = {
      printing = true;
      docker = true;
      gaming = true;
    };

    home = {
      compositor = "niri";
      desktopComponents = [
        "noctalia"
        "kanshi"
        "swayidle"
        "windows-spotlight"
      ];
      terminals = [
        "ghostty"
        "kitty"
        "alacritty"
      ];
      defaultTerminal = "kitty";
      editors = [
        "nvim"
        "vim"
        "vscode"
        "antigravity"
      ];
      screenshots = [
        # Only flameshot is active on x1carbon today; satty/grimblast are
        # available as selectors but not currently enabled.
        "flameshot"
      ];
      obsidian = true;
      chromium = true;
    };
  };

  # --- host identity (moved verbatim from the old hosts/x1carbon/default.nix) --

  # avoid inputs of this flake from being garbage-collected.
  system.extraDependencies =
    let
      collectFlakeInputs =
        input:
        [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
    in
    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);

  # Enable builds for rpi.
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostName = "x1carbon"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "ja_JP.UTF-8";
  };

  # Enable touchpad support (enabled by default in most desktopManager).
  services.libinput.enable = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts-cjk-sans
      nerd-fonts.hack
      nerd-fonts.roboto-mono
      nerd-fonts.intone-mono
    ];
  };

  programs.gnupg.agent = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "24.11"; # Did you read the comment?
}
