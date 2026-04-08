{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

with pkgs; with lib;
let
  brightnessctlBin = "${getExe brightnessctl}";
  noctaliaBin = "${getExe' noctalia-shell "noctalia-shell"}";
  noctalia-lock = "${noctaliaBin} ipc call lockScreen lock";
  niriBin = "${getExe' niri "niri"}";
  niri-monitor = status: "${niriBin} msg action power-${status}-monitors";
  systemctlBin = "${getExe' systemd "systemctl"}";
in
{
  home.packages = with pkgs; [
    brightnessctl
  ];

  services.swayidle = {
    enable = true;
    systemdTargets = [ "niri.service" ];
    extraArgs = [ "-w" ];
    events = {
      "before-sleep" = noctalia-lock;
      "after-resume" = niri-monitor "on";
      "lock" = noctalia-lock;
      "unlock" = niri-monitor "on";
    };
    timeouts = [
      {
        timeout = 150; # 2.5min
        command = "${brightnessctlBin} -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
        resumeCommand = "${brightnessctlBin} -r"; # monitor backlight restore.
      }
      {
        timeout = 300; # 5min
        command = noctalia-lock;
      }
      {
        timeout = 330; # 5.5min
        command = niri-monitor "off";
        resumeCommand = (niri-monitor "on") + " && ${brightnessctlBin} -r";
      }
      {
        timeout = 1800; # 30min
        command = "${systemctlBin} suspend";
      }
    ];
  };
}
