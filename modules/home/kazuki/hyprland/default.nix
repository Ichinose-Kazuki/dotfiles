# https://github.com/turtton/dotnix/tree/daa44ea1c09d16a9ecfcd610b66d7a5d5dbc1708/home-manager/wm/hyprland

{
  pkgs,
  inputs,
  system,
  lib,
  ...
}:
{
  imports = [
    ./eww
    ./qt
    ./rofi
    # ./waybar
    ./wlogout
    # ./dunst.nix
    ./gtk.nix
    ./key-bindings.nix
    ./settings.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpanel.nix
    ./utilapp.nix
    #./wofi.nix
  ];

  wayland.windowManager.hyprland.settings = {
    # check `hyprctl monitors all`
    monitor = [
      "DP-1, 1920x1080@144, 0x0, 1"
      "HDMI-A-1, 1920x1080@60, 1920x0, 1"
      "DVI-D-1, 1920x1080@60, -1900x-1080, 1"
      ",preferred,auto,1"
    ];
    input = {
      sensitivity = lib.mkForce "-0.45";
      accel_profile = "flat";
      kb_layout = "us";
    };
    exec-once = [
      "bitwarden"
      "[workspace 1 silent] vesktop"
      "steam -silent"
      "KEYBASE_AUTOSTART=1 keybase-gui"
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    plugins = [
      inputs.split-monitor-workspaces.packages.${system}.split-monitor-workspaces
    ];
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    systemd.variables = [ "--all" ];
  };

  home.packages = with pkgs; [
    brightnessctl # screen brightness
    grimblast # screenshot
    swappy # image editor for screenshots
    zenity # create screenshot save dialog
    hyprpicker # color picker
    pamixer # pulseaudio mixer
    playerctl # media player control
    swww # wallpaper
    wayvnc # vnc server
    wev # key event watcher
    wireplumber # screens sharing
    wf-recorder # screen recorder
    wl-clipboard # clipboard manager
    cliphist # clipboard history
    polkit
    inputs.hyprpolkitagent.packages.${system}.hyprpolkitagent # password prompt
    # libsForQt5.polkit-kde-agent # password prompt(kde)
    libsecret # keyring
    networkmanagerapplet # network manager gui
  ];

  xdg.userDirs.createDirectories = true;
  services = {
    gnome-keyring.enable = true;
    kdeconnect.indicator = true;
  };
}

# {
#   inputs,
#   lib,
#   pkgs,
#   ...
# }:

# {
#   programs.kitty.enable = true; # required for the default Hyprland config
#   wayland.windowManager.hyprland = {
#     enable = true;
#     systemd.variables = [ "--all" ];
#     # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
#     package = null;
#     portalPackage = null;
#   };

#   # Optional, hint Electron apps to use Wayland:
#   home.sessionVariables.NIXOS_OZONE_WL = "1";

#   wayland.windowManager.hyprland.settings = {
#     "$mod" = "SUPER";
#     bind =
#       [
#         "$mod, F, exec, firefox"
#         "$mod, C, exec, code"
#         "$mod, Q, exec, kitty"
#         ", Print, exec, grimblast copy area"
#       ]
#       ++ (
#         # workspaces
#         # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
#         builtins.concatLists (
#           builtins.genList (
#             i:
#             let
#               ws = i + 1;
#             in
#             [
#               "$mod, code:1${toString i}, workspace, ${toString ws}"
#               "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
#             ]
#           ) 9
#         )
#       );
#   };
# }
