# Shared myModule option schema (Dendritic pattern).
#
# This single file is imported into BOTH the NixOS eval and the home-manager
# eval so the selector schema is declared once. Hosts set values at the NixOS
# level (see hosts/<host>/host.nix); home-manager leaves read the values via
# `osConfig.myModule.*`. Leaf modules branch on these values with `lib.mkIf`.
#
# Form: selectors (enum) + lists. `enable` flags are avoided as the basic form.
# WIP/disabled modules are kept as valid enum values — they simply aren't
# selected, so `mkIf` disables them naturally.
{ lib, ... }:

let
  inherit (lib) mkOption types;
in
{
  options.myModule = {
    # Machine form factor — drives derived defaults (e.g. battery on laptops).
    machine = mkOption {
      type = types.enum [
        "laptop"
        "desktop"
        "server"
        "sbc"
      ];
      default = "desktop";
      description = "Physical form factor of the host.";
    };

    # --- NixOS-side desktop selectors -------------------------------------
    desktop = {
      compositor = mkOption {
        type = types.enum [
          "niri"
          "hyprland"
          "sway"
          "none"
        ];
        default = "none";
        description = "Wayland compositor (system-level enablement).";
      };
      displayManager = mkOption {
        type = types.enum [
          "regreet"
          "sddm"
          "ly"
          "none"
        ];
        default = "none";
        description = "Display manager / greeter.";
      };
      lockscreen = mkOption {
        type = types.enum [
          "gtklock"
          "none"
        ];
        default = "none";
        description = "Screen locker (independent of the display manager).";
      };
      components = mkOption {
        type = types.listOf (types.enum [
          "wayland-utils"
          "kdePlasma"
          "files"
          "gpu-recorder"
          "wtfutil"
          "programs"
        ]);
        default = [ ];
        description = "Optional system-level desktop components.";
      };
    };

    # --- NixOS-side system selectors --------------------------------------
    keyring = mkOption {
      type = types.enum [
        "gnome-keyring"
        "kwallet"
        "none"
      ];
      default = "none";
      description = "Secret-service / keyring backend.";
    };
    location = mkOption {
      type = types.bool;
      default = false;
      description = "Enable geoclue2-based location services.";
    };
    tailscale = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the Tailscale VPN daemon.";
    };

    # Hardware toggles — normally DERIVED (see my-module-derived.nix) from
    # `machine` / `desktop`, but declared here so a host can override them.
    hardware = {
      sound = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the PipeWire audio stack.";
      };
      printing = mkOption {
        type = types.bool;
        default = false;
        description = "Enable CUPS + Avahi printer discovery.";
      };
      docker = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the Docker daemon.";
      };
      gaming = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Steam and gaming support.";
      };
      battery = mkOption {
        type = types.bool;
        default = false;
        description = "Enable UPower battery management.";
      };
    };

    # --- home-manager-side selectors --------------------------------------
    # Set under `myModule.home.*` at the NixOS level; home leaves read these
    # through `osConfig.myModule.home.*`.
    home = {
      compositor = mkOption {
        type = types.enum [
          "niri"
          "hyprland"
          "sway"
          "plasma"
          "none"
        ];
        default = "none";
        description = "User-level compositor / desktop environment.";
      };
      desktopComponents = mkOption {
        type = types.listOf (types.enum [
          "noctalia"
          "waybar"
          "kanshi"
          "swayidle"
          "windows-spotlight"
        ]);
        default = [ ];
        description = "User-level desktop shell components.";
      };
      terminals = mkOption {
        type = types.listOf (types.enum [
          "ghostty"
          "kitty"
          "alacritty"
        ]);
        default = [ ];
        description = "Terminal emulators to install.";
      };
      defaultTerminal = mkOption {
        type = types.str;
        default = "kitty";
        description = "Value of the $TERMINAL session variable.";
      };
      editors = mkOption {
        type = types.listOf (types.enum [
          "nvim"
          "vim"
          "vscode"
          "antigravity"
        ]);
        default = [
          "nvim"
          "vim"
        ];
        description = "Editors to install.";
      };
      screenshots = mkOption {
        type = types.listOf (types.enum [
          "flameshot"
          "satty"
          "grimblast"
        ]);
        default = [ ];
        description = "Screenshot tools to install.";
      };
      obsidian = mkOption {
        type = types.bool;
        default = false;
        description = "Install and configure Obsidian.";
      };
      chromium = mkOption {
        type = types.bool;
        default = false;
        description = "Install and configure the Chromium/Chrome browser.";
      };
    };

    # --- shared / misc ----------------------------------------------------
    shell.zshUserNameColor = mkOption {
      type = types.str;
      default = "blue";
      description = "grml zsh prompt username colour (name or 256-colour code).";
    };
  };
}
