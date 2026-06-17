{
  lib,
  lockCommand,
  powerMenuXml,
}:

{
  # config options: https://github.com/Alexays/Waybar/wiki/Configuration
  # available modules: https://github.com/Alexays/Waybar/wiki#:~:text=FAQ-,Modules,-%3A
  # modules for hyprland: https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
  # hyprland wiki: https://wiki.hypr.land/Useful-Utilities/Status-Bars/#waybar
  myConfig = {
    # Bar Config
    layer = "top";
    position = "top";
    height = 20;
    modules-left = [
      "hyprland/workspaces"
      "cpu"
      "memory"
      "temperature"
      "power-profiles-daemon" # not working rn
      "battery"
      "hyprland/submap"
    ];
    modules-center = [ "clock" ];
    modules-right = [
      "custom/notification"
      "mpd"
      "tray"
      "idle_inhibitor"
      "pulseaudio"
      "custom/power"
    ];
    spacing = 3;

    # Module Config
    battery = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% {icon}";
      format-charging = "{capacity}% 🗲";
      format-plugged = "{capacity}% ";
      format-alt = "{time} {icon}";
      format-icons = [
        ""
        ""
        ""
        ""
        ""
      ];
    };
    clock = {
      format = "{:%a %e %b %H:%M}"; # padding_modifier doesn't seem to be supported
      tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
    };
    cpu = {
      format = "{usage}% ";
      tooltip = false;
    };
    "custom/notification" = {
      tooltip = false;
      format = "{} {icon}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span> ";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span> ";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span> ";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span> ";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "sleep 0.1 && swaync-client -t -sw";
      on-click-right = "swaync-client -d -sw";
      escape = true;
    };
    "custom/power" = {
      format = "⏻ ";
      tooltip = false;
      menu = "on-click";
      menu-file = "${powerMenuXml}"; # Menu file in resources folder
      menu-actions = {
        shutdown = "poweroff";
        reboot = "reboot";
        suspend = "systemctl suspend";
        hibernate = "systemctl hibernate";
        logout = "uwsm stop"; # https://wiki.hypr.land/Configuring/Dispatchers/
        lock = "${lockCommand}";
      };
    };
    idle_inhibitor = {
      format = "{icon}";
      format-icons = {
        activated = "";
        deactivated = "";
      };
    };
    memory = {
      format = "{}% ";
    };
    mpd = {
      format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
      format-disconnected = "Disconnected ";
      format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
      unknown-tag = "N/A";
      interval = 2;
      consume-icons = {
        on = " ";
      };
      random-icons = {
        off = "<span color=\"#f53c3c\"></span> ";
        on = " ";
      };
      repeat-icons = {
        on = " ";
      };
      single-icons = {
        on = "1 ";
      };
      state-icons = {
        paused = "";
        playing = "";
      };
      tooltip-format = "MPD (connected)";
      tooltip-format-disconnected = "MPD (disconnected)";
    };
    pulseaudio = {
      # "scroll-step"= 10, # %, can be a float
      format = "{volume}%{icon} {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = " {icon} {format_source}";
      format-muted = " {format_source}";
      format-source = "{volume}% ";
      format-source-muted = "";
      format-icons = {
        headphone = "";
        hands-free = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [
          ""
          ""
          ""
        ];
      };
      on-click = "pavucontrol";
    };
    temperature = {
      # "thermal-zone"= 2;
      # "hwmon-path"= "/sys/class/hwmon/hwmon2/temp1_input";
      critical-threshold = 80;
      # "format-critical"= "{temperatureC}°C {icon}";
      format = "{temperatureC}°C {icon}";
      format-icons = [
        ""
        ""
        ""
      ];
    };
    tray = {
      spacing = 0;
    };
  };
}
