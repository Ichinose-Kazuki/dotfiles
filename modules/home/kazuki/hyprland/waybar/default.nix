{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

let
  cfg = config.my-waybar;
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      pygobject3
    ]
  );
  mediaplayer = pkgs.writeScriptBin "waybar-mediaplayer" ''
    #!/bin/sh
    ${pythonEnv}/bin/python ${./mediaplayer.py} "$@"
  '';
  powerMenuXml = pkgs.writeTextFile {
    name = "power_menu.xml";
    text = builtins.readFile ./power_menu.xml;
  };
in

{
  options.my-waybar = with lib.types; {
    enable = lib.options.mkEnableOption "my-waybar";
  };

  config = lib.modules.mkIf cfg.enable {

    home.packages = with pkgs; [
      font-awesome
      roboto
      mediaplayer
      # gobject dependencies
      playerctl
      gobject-introspection
      # pipewire controller on status bar
      pavucontrol
    ];

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      # refer to https://wiki.hypr.land/Useful-Utilities/Status-Bars/#waybar for hyprland specific configs.
      style = ./coffeebar.css;
    };
    xdg.configFile."waybar/config" = {
      text = ''
        {
          "layer": "top", // Waybar at top layer
          "position": "top", // Waybar position (top|bottom|left|right)
          "height": 20, // Waybar height (to be removed for auto height)
          // "width": 1280, // Waybar width
          "spacing": 3, // Gaps between modules (4px)
          // Choose the order of the modules
          "modules-left": ["hyprland/workspaces", "idle_inhibitor", "pulseaudio", "custom/media", "backlight", "network"],
          "modules-center": ["hyprland/window"],
          "modules-right": ["hyprland/submap", "hyprland/language", "cpu", "memory", "temperature", "battery", "tray", "clock", "custom/power"],
          // Modules configuration
           "hyprland/workspaces": {
               "disable-scroll": true,
               "on-click": "activate",
               // "all-outputs": false,
               // "format": "{name}: {icon}",
               "format": "{name}",
               "on-scroll-up": "hyprctl dispatch workspace m-1 > /dev/null",
               "on-scroll-down": "hyprctl dispatch workspace m+1 > /dev/null",
               "format-icons": {
                   "1": "",
                   "2": "",
                   "3": "",
                   "4": "",
                   "5": "",
                   "urgent": "",
                   "focused": "",
                   "default": ""
               }
           },
          "keyboard-state": {
              "numlock": false,
              "capslock": false,
              "format": "{name} {icon}",
              "format-icons": {
                  "locked": "",
                  "unlocked": ""
              }
          },
          "hyprland/window": {
              "max-length": 50,
              "separate-outputs": true
          },
          "hyprland/language": {
              "format": "{}",
              "max-length": 18
          },
          "sway/mode": {
              "format": "<span style=\"italic\">{}</span>"
          },
          "sway/scratchpad": {
              "format": "{icon} {count}",
              "show-empty": false,
              "format-icons": ["", ""],
              "tooltip": true,
              "tooltip-format": "{app}: {title}"
          },
          "mpd": {
              "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ",
              "format-disconnected": "Disconnected ",
              "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ",
              "unknown-tag": "N/A",
              "interval": 2,
              "consume-icons": {
                  "on": " "
              },
              "random-icons": {
                  "off": "<span color=\"#f53c3c\"></span> ",
                  "on": " "
              },
              "repeat-icons": {
                  "on": " "
              },
              "single-icons": {
                  "on": "1 "
              },
              "state-icons": {
                  "paused": "",
                  "playing": ""
              },
              "tooltip-format": "MPD (connected)",
              "tooltip-format-disconnected": "MPD (disconnected)"
          },
          "idle_inhibitor": {
              "format": "{icon}",
              "format-icons": {
                  "activated": "",
                  "deactivated": ""
              }
          },
          "tray": {
              // "icon-size": 21,
              "spacing": 0
          },
          "clock": {
              // "timezone": "America/New_York",
              "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
              "format-alt": "{:%Y-%m-%d}"
          },
          "cpu": {
              "format": "{usage}% ",
              "tooltip": false
          },
          "memory": {
              "format": "{}% "
          },
          "temperature": {
              // "thermal-zone": 2,
              // "hwmon-path": "/sys/class/hwmon/hwmon2/temp1_input",
              "critical-threshold": 80,
              // "format-critical": "{temperatureC}°C {icon}",
              "format": "{temperatureC}°C {icon}",
              "format-icons": ["", "", ""]
          },
          "backlight": {
              // "device": "acpi_video1",
              "format": "{percent}% {icon}",
              "format-icons": ["", "", "", "", "", "", "", "", ""]
          },
          "battery": {
              "states": {
                  // "good": 95,
                  "warning": 30,
                  "critical": 15
              },
              "format": "{capacity}% {icon}",
              "format-charging": "{capacity}% 🗲",
              "format-plugged": "{capacity}% ",
              "format-alt": "{time} {icon}",
              // "format-good": "", // An empty format will hide the module
              // "format-full": "",
              "format-icons": ["", "", "", "", ""]
          },
          "battery#bat2": {
              "bat": "BAT2"
          },
          "network": {
              // "interface": "wlan0", // (Optional) To force the use of this interface
              "format-wifi": "",
              "format-ethernet": "",
              "tooltip-format": "{ifname} via {gwaddr} ",
              "format-linked": "{ifname} (No IP) ",
              "format-disconnected": "⚠",
              "format-alt": "{ifname}: {ipaddr}/{cidr}"
          },
          "pulseaudio": {
              // "scroll-step": 10, // %, can be a float
              "format": "{volume}%{icon} {format_source}",
              "format-bluetooth": "{volume}% {icon} {format_source}",
              "format-bluetooth-muted": " {icon} {format_source}",
              "format-muted": " {format_source}",
              "format-source": "{volume}% ",
              "format-source-muted": "",
              "format-icons": {
                  "headphone": "",
                  "hands-free": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", "", ""]
              },
              "on-click": "pavucontrol"
          },
          "custom/notification": {
              "tooltip": false,
              "format": "{} {icon}",
              "format-icons": {
                  "notification": "<span foreground='red'><sup></sup></span> ",
                  "none": "",
                  "dnd-notification": "<span foreground='red'><sup></sup></span> ",
                  "dnd-none": "",
                  "inhibited-notification": "<span foreground='red'><sup></sup></span> ",
                  "inhibited-none": "",
                  "dnd-inhibited-notification": "<span foreground='red'><sup></sup></span> ",
                  "dnd-inhibited-none": ""
              },
              "return-type": "json",
              "exec-if": "which swaync-client",
              "exec": "swaync-client -swb",
              "on-click": "sleep 0.1 && swaync-client -t -sw",
              "on-click-right": "swaync-client -d -sw",
              "escape": true
          },
          "custom/media": {
            "format": "{icon} {text}",
            "return-type": "json",
            "max-length": 40,
            "format-icons": {
              "spotify": "",
              "default": "🎜"
            },
            "escape": true,
            "exec": "${lib.getExe' mediaplayer "waybar-mediaplayer"} 2> /dev/null" // Script in resources folder
            // "exec": "$HOME/.config/waybar/mediaplayer.py --player spotify 2> /dev/null" // Filter player based on name
          },
          "custom/power": {
            "format" : "⏻ ",
            "tooltip": false,
            "menu": "on-click",
            "menu-file": "${powerMenuXml}", // Menu file in resources folder
            "menu-actions": {
              "shutdown": "shutdown",
              "reboot": "reboot",
              "suspend": "systemctl suspend",
              "hibernate": "systemctl hibernate",
              "logout": "uwsm stop" // https://wiki.hypr.land/Configuring/Dispatchers/
            }
          }
        }
      '';
      onChange = ''
        ${pkgs.procps}/bin/pkill -u $USER -USR2 waybar || true
      '';
    };
  };
}
