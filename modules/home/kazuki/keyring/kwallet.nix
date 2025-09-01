{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

{
  # systemd.user.services.kwalletd = {
  #   Unit = {
  #     Description = "KDE Wallet Manager";
  #     PartOf = [ "graphical-session.target" ];
  #   };

  #   Service = {
  #     Type = "dbus";
  #     BusName = "org.kde.kwalletd5";
  #     ExecStart = "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator";
  #     Restart = "on-failure";
  #   };

  #   Install = {
  #     WantedBy = [ default.target ];
  #   };
  # };

  # dbus.packages = with pkgs; [
  #   kdePackages.kwallet
  # ];
}
