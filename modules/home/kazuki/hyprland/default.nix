{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  qt6ct-kde = pkgs.callPackage ../../../pkgs/qt6ct-kde {
    inherit (pkgs.kdePackages)
      qtbase
      qtsvg
      qttools
      qtwayland
      wrapQtAppsHook
      ;
  };
in
{
  imports = [
    ./must-have.nix
    ./hypr-ecosystem.nix
    ./other-utils.nix
  ];

  home.packages = with pkgs; [
    # theme
    # qt5 variants conflict with these qt6 variants. qt5 is installed along with qt6...?
    # Other attractive themes include Layan, Qogir, and Sweet, but their appearance isn't very consistent between Qt and GTK.
    qt6ct-kde # doesn't work like this: https://www.lorenzobettini.it/2024/08/better-kde-theming-and-styling-in-hyprland/
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.kcolorscheme # Breeze Dark
    kdePackages.qtstyleplugin-kvantum
    kdePackages.breeze-gtk
    dejavu_fonts # default fonts for kde apps.
    playerctl
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = osConfig.programs.hyprland.package; # enable auto reload.
    portalPackage = null; # portal package is added forcibly in nixos module.
    # config: see https://wiki.hypr.land/Configuring
    settings = {
      # monitors
      monitor = ",preferred,auto,auto";
      # my programs
      "$terminal" = "konsole";
      "$fileManager" = "dolphin";
      "$menu" = "walker";
      # Don't set env here: https://wiki.hypr.land/Configuring/Environment-variables/
      # permissions
      # look and feel: https://wiki.hypr.land/Configuring/Variables/
      general = rec {
        border_size = 2;
        gaps_in = (8 - border_size) / 2; # 2*gaps_in between windows.
        gaps_out = (8 - border_size);
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "master";
      };
      decoration = {
        rounding = 10;
        blur.enabled = false; # saves on battery.
        shadow = {
          enabled = false; # saves on battery.
          color = "rgba(1a1a1aaf)";
        };
      };

      # https://wiki.hyprland.org/Configuring/Variables/#animations
      animations = {
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
      };
      master = {
        mfact = 0.50;
      };
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        disable_autoreload = true; # might save on battery.
        close_special_on_empty = false;
        vfr = true; # saves on battery.
      };
      # input
      # refer to https://wayland-book.com/seat/xkb.html for details of xkb.
      input = {
        repeat_delay = 300;
        sensitivity = 0.5; # -1.0 - 1.0, 0 means no modification.
        accel_profile = "adaptive";

        touchpad = {
          natural_scroll = false;
          tap-to-click = false;
          tap-and-drag = false;
        };
      };
      gestures = {
        workspace_swipe = false;
      };
      xwayland = {
        # Less secure but more compatible.
        # Abstract sockets exist in a kernel-managed namespace independent of the filesystem,
        # identified by a null byte (\0) prefix in their name.
        # Many X11 applications prefer abstract sockets for flexibility,
        # as they bypass filesystem permissions.
        create_abstract_socket = true;
      };
      render = {
        # direct_scanout = 1; # seems useful, but causes problems with many GPUs.
      };
      cursor = {
        # persistent_warps = true; # probably useful with a track ball mouse.
      };
      ecosystem = {
        # no_donation_nag = true;
        enforce_permissions = true;
      };
      # keybindings
      "$mainMod" = "ALT";
      # This works as if, every time a key is pressed, hyprctl reads through
      # all the (in-memory) keybinds from top to bottom and dispatches all matching ones.
      bind = [
        "$mainMod + SHIFT, Q, killactive,"
        "$mainMod, F, fullscreen, 0"
        # "$mainMod, F, fullscreenstate, 0" # send fullscreen state to client app?
        "$mainMod + SHIFT, T, exec, $terminal"
        "$mainMod + SHIFT, E, exec, $fileManager"
        "$mainMod, SPACE, exec, $menu"

        # Move focus with mainMod + hjkl
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Move active window in a direction with mainMod + SHIFT + hjkl
        "$mainMod + SHIFT, h, movewindow, l"
        "$mainMod + SHIFT, l, movewindow, r"
        "$mainMod + SHIFT, k, movewindow, u"
        "$mainMod + SHIFT, j, movewindow, d"

        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod + SHIFT, 1, movetoworkspace, 1"
        "$mainMod + SHIFT, 2, movetoworkspace, 2"
        "$mainMod + SHIFT, 3, movetoworkspace, 3"
        "$mainMod + SHIFT, 4, movetoworkspace, 4"
        "$mainMod + SHIFT, 5, movetoworkspace, 5"
        "$mainMod + SHIFT, 6, movetoworkspace, 6"
        "$mainMod + SHIFT, 7, movetoworkspace, 7"
        "$mainMod + SHIFT, 8, movetoworkspace, 8"
        "$mainMod + SHIFT, 9, movetoworkspace, 9"
        "$mainMod + SHIFT, 0, movetoworkspace, 10"

        # Example special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace,"
        "$mainMod SHIFT, S, movetoworkspace, special"

        # Global Keybinds
        "SUPER, F10, pass, class:^(com\.obsproject\.Studio)$"
        # See also: https://wiki.hypr.land/Configuring/Binds/#dbus-global-shortcuts
      ];

      # m, e, l in bindm, bindel are flags: https://wiki.hypr.land/Configuring/Binds/#bind-flags

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Laptop multimedia keys for volume and LCD brightness
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      bindl = [
        # Requires playerctl
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        # Switches
        # View switches in `hyprctl devices`
        # Only Lid Switch is found on my ThinkPad.
        # eDP-1 is the internal monitor.
        # Lock if no external monitor is connected.
        ", switch:Lid Switch, exec, [ \"$(hyprctl monitors | grep \"Monitor\" | awk '{print $2}')\" = \"eDP-1\" ] && hyprlock"
        ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,disable\""
        ", switch:off:Lid Switch, exec, hyprctl keyword monitor \"eDP-1,preferred,auto,auto\""
      ];
      # windows and workspaces
      windowrule = [
        "suppressevent maximize, class:.*"
        # Fix some dragging issues with XWayland
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
    };

    # Submaps have to be declared this way.
    extraConfig = ''
      bind = ALT, R, submap, resize
      submap = resize

      binde = , l, resizeactive, 10 0
      binde = , h, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10

      # use reset to go back to the global submap
      # reset is a special mapping name meaning global.
      # * - NEVER FAIL TO ADD THESE LINES. - *
      bind = , catchall, submap, reset 
      submap = reset 
      # * ---------------------------------- *
    '';
  };

  # environment variables: https://wiki.hypr.land/Configuring/Environment-variables/
  # theming, xcursor, nvidia and toolkit variables
  # uniform look for Qt and GTK apps: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
  # note that QT_QPA_PLATFORMTHEME is applied to non-KDE apps only.
  # for KDE apps, edit their rc files in $XDG_CONFIG_HOME. e.g. konsolerc.
  # kvantum, qt6ct etc does not work rn.
  xdg.configFile."uwsm/env".text = ''
    export XCURSOR_SIZE=24

    export GTK_THEME=Breeze-Dark
    export QT_QPA_PLATFORMTHEME=qt6ct
    export QT_STYLE_OVERRIDE=kvantum

    export QT_AUTO_SCREEN_SCALE_FACTOR=1
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

    export GDK_BACKEND=wayland,x11,*
    export QT_QPA_PLATFORM=wayland;xcb
    export SDL_VIDEODRIVER=wayland
    export CLUTTER_BACKEND=wayland
  '';
  # HYPR* and AQ_* variables
  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRCURSOR_SIZE=24
  '';
  # todo: XCURSOR_THEME

  xdg.portal = {
    enable = lib.mkForce true; # is set false in the hyprland module.
    xdgOpenUsePortal = true; # resolves bugs involving programs opening inside FHS etc.
    extraPortals =
      (with pkgs; [
        xdg-desktop-portal-gtk
        kdePackages.xdg-desktop-portal-kde # needed for kde file picker
      ]) # coverage of each portal: https://wiki.archlinux.org/title/XDG_Desktop_Portal. xdg-desktop-portal-hyprland is added in the hyprland module.
      ++ osConfig.xdg.portal.extraPortals; # https://github.com/nix-community/home-manager/issues/7124
  };

  # let xdph use kde file picker.
  xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = lib.generators.toINI { } {
    preferred = {
      default = "hyprland;gtk";
      "org.freedesktop.impl.portal.FileChooser" = "kde";
    };
  };
}
