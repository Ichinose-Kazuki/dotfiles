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
    enable = true;
    settings = {
      "$font" = "Monospace";

      general = {
        hide_cursor = false;
      };

      # auth = {
      #   fingerprint = {
      #     enabled = true;
      #     ready_message = "Scan fingerprint to unlock";
      #     present_message = "Scanning...";
      #     retry_delay = 250; # in milliseconds
      #   };
      # };

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

          outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
          fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

          font_color = "rgb(143, 143, 143)";
          fade_on_empty = false;
          rounding = 15;

          font_family = "$font";
          placeholder_text = "Input password...";
          fail_text = "$PAMFAIL";

          # uncomment to use a letter instead of a dot to indicate the typed password
          # dots_text_format = *
          # dots_size = 0.4
          dots_spacing = 0.3;

          # uncomment to use an input indicator that does not show the password length (similar to swaylock's input indicator)
          # hide_input = true

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

          position = "-30, 0";
          halign = "right";
          valign = "top";
        }

        # DATE
        {
          monitor = "";
          text = "cmd[update:60000] date +\"%A, %d %B %Y\""; # update every 60 seconds
          font_size = 25;
          font_family = "$font";

          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
    };
  };

  # blue light filter
  services.hyprsunset = {
    enable = true;
  };

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
}
