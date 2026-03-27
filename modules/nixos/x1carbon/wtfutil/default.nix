{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    wtfutil
  ];

  imports = [
    ./config.yml.nix
  ];

  systemd.user.services.startup-dashboard = {
    description = "Startup WTF Dashboard";

    wantedBy = [ "graphical-session.target" ];

    after = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";

      ExecStart = "${lib.getExe pkgs.kitty} --class startup-wtf-dashboard -o window_padding_width=20 -o confirm_os_window_close=0 -e ${lib.getExe pkgs.wtfutil} --config=/etc/startup-wtf-dashboard.yml";
      Restart = "no";
    };
  };
}
