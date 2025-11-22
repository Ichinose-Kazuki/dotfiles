{ config, pkgs, ... }:

let
  manageMonitorsScript = ".config/hypr/manage-monitors.sh";

in
{
  home.packages = with pkgs; [
    jq
    socat
  ];

  home.file."${manageMonitorsScript}" = {
    source = ./toggle-internal-monitor.sh;
    executable = true;
  };

  systemd.user.services.toggle-internal-monitor = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };

    Unit = {
      Description = "Disable internal monitor when ≥2 external monitors are connected";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 3;
      Environment = "PATH=${pkgs.coreutils}/bin:${pkgs.hyprland}/bin:${pkgs.bash}/bin:${pkgs.jq}/bin:${pkgs.socat}/bin";
      ExecStart = "${config.home.homeDirectory}/${manageMonitorsScript}";
    };
  };
}
