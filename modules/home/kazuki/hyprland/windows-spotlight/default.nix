{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      requests
    ]
  );
  fetchScript = pkgs.writeScriptBin "fetch-windows-spotlight" ''
    #!/bin/sh
    ${pythonEnv}/bin/python ${./fetch.py} $1
  '';
  cfg = config.windows-spotlight;
in
{
  options.windows-spotlight = {
    imageFilepath = lib.mkOption {
      type = lib.types.str;
    };
    requiredService = lib.mkOption {
      type = lib.types.str;
    };
    reloadCommand = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = {
    home.packages = [ fetchScript ];

    systemd.user.services.windows-spotlight = {
      Install = {
        WantedBy = [ config.wayland.systemd.target ];
      };

      Unit = {
        ConditionEnvironment = "WAYLAND_DISPLAY";
        Description = "fetch windows spotlight";
        After = [ config.wayland.systemd.target ];
        PartOf = [ config.wayland.systemd.target ];
        Requires = [ cfg.requiredService ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' fetchScript "fetch-windows-spotlight"} \"${cfg.imageFilepath}\"";
        ExecStartPost = cfg.reloadCommand;
        Restart = "on-failure";
      };
    };

    systemd.user.timers.windows-spotlight = {
      Install = {
        WantedBy = [ "timers.target" ];
      };

      Unit = {
        Description = "run windows-spotlight unit every 24h";
      };

      Timer = {
        # テスト用
        OnUnitActiveSec = "3s";
        AccuracySec = "1s";
        Persistent = true;
      };
    };
  };
}
