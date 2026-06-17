{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  wallpaperPath = "${config.xdg.dataHome}/windows_spotlight/image.jpg";
  lockscreen = "gtklock";
  lockCommand = "${lib.getExe osConfig.programs.gtklock.package} -d"; # gtklock -d when it is being automatically invoked by something like swayidle
in
{
  config = lib.mkIf (osConfig.myModule.home.compositor == "hyprland") {
    home.packages = with pkgs; [
      # color picker
      hyprpicker
      # system info
      hyprsysteminfo # temporary fix
      # hyprsysteminfo
      # Qt6 QML provider for hypr* apps
      hyprland-qt-support
      # idle management
      brightnessctl
      # hyprcursor
      hyprcursor
      rose-pine-hyprcursor
    ];

    # wallpaper
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ wallpaperPath ];
        wallpaper = [ wallpaperPath ];
      };
    };
    windows-spotlight = {
      enable = true;
      imageFilepath = wallpaperPath;
      requiredService = "hyprpaper.service";
      reloadCommand = "${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper wallpaper \", ${wallpaperPath}\"";
    };

    # idle management
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof ${lockscreen} || ${lockCommand}"; # avoid starting multiple lockscreen instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    # hyprlock
    # example conf: https://github.com/hyprwm/hyprlock/blob/main/assets/example.conf
    programs.hyprlock = {
      enable = false;
      settings = {
        "$font" = "Monospace";

        general = {
          hide_cursor = false;
        };

        animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fadeIn, 1, 5, linear"
            "fadeOut, 1, 5, linear"
            "inputFieldDots, 1, 2, linear"
          ];
        };

        background = [
          {
            monitor = "";
            path = wallpaperPath;
            blur_passes = 3;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "20%, 5%";
            outline_thickness = 3;
            inner_color = "rgba(0, 0, 0, 0.0)"; # no fill

            outer_color = config.wayland.windowManager.hyprland.settings.general."col.active_border";
            check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
            fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

            font_color = "rgb(143, 143, 143)";
            fade_on_empty = false;
            rounding = 15;

            font_family = "$font";
            placeholder_text = "Input password...";
            fail_text = "$PAMFAIL";

            dots_spacing = 0.3;

            position = "0, -20";
            halign = "center";
            valign = "center";
          }
        ];

        label = [
          # TIME
          {
            monitor = "";
            text = "$TIME"; # ref. https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#variable-substitution
            font_size = 90;
            font_family = "$font";
            position = "0, 170";
          }

          # DATE
          {
            monitor = "";
            text = "cmd[update:60000] LC_TIME=en_US.UTF-8 date +\"%a %-d %b\""; # update every 60 seconds
            font_size = 25;
            font_family = "$font";
            position = "0, 90";
          }
        ];
      };
    };

    # blue light filter
    services.hyprsunset = {
      enable = true;
      settings = {
        profile = [
          # sunrise
          {
            time = "7:00";
            identity = true;
          }
          # sunset
          {
            time = "23:00";
            temperature = 3500;
          }
        ];
      };
    };
    systemd.user.services.hyprsunset.Service.StandardOutput = "null"; # workaround for hyprsunset spamming the journal

    # cursor theme
    # hyprcursor settings are done in hyprland/default.nix.
    # GTK doesn't support hyprcursor.
    gtk = {
      enable = true;
      cursorTheme = {
        name = "BreezeX-RosePine-Linux";
        package = pkgs.rose-pine-cursor;
        size = 32;
      };
    };
  };
}
