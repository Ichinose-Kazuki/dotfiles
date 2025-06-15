{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  wallpaperPath = "${config.xdg.dataHome}/windows_spotlight/image.jpg";
in
{
  imports = [
    # wallpaper
    ./windows-spotlight
  ];

  home.packages = with pkgs; [
    # color picker
    hyprpicker
    # system info
    hyprsysteminfo
    # Qt6 QML provider for hypr* apps
    hyprland-qt-support
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
    imageFilepath = wallpaperPath;
    requiredService = "hyprpaper.service";
    reloadCommand = "${lib.getExe' pkgs.hyprland "hyprctl"} hyprpaper reload ,\"${wallpaperPath}\"";
  };

  # idle management
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
        before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
        after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
      };

      listener = [
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
          on-resume = "brightnessctl -r"; # monitor backlight restore.
        }
        # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
        {
          timeout = 150; # 2.5min.
          on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
          on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
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
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 300;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = wallpaperPath;
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''<i><span foreground="##cad3f5">Password...</span></i>'';
          shadow_passes = 2;
        }
      ];
    };
  };

  # blue light filter
  services.hyprsunset = {
    enable = true;
  };
}
