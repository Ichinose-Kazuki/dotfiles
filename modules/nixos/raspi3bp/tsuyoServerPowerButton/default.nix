{ pkgs, ... }:

let
  pythonLibgpiod = (pkgs.python312.withPackages
    (p: with p; [
      libgpiod
    ]));
in
{
  environment.systemPackages = with pkgs;
    [
      pythonLibgpiod
      libgpiod
      gcc
    ];

  # Run the power button script on boot
  systemd.services.tsuyoServerPowerButtonService = {
    description = "tsuyoServer Power Button Service";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iputils wol ]; # ping command in the script
    serviceConfig = {
      ExecStart = "${pythonLibgpiod}/bin/python ${./watch_power_button.py}";
      Restart = "always";
    };
  };
}
