{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./my_geoclue.nix ];

  services.mygeoclue2 = {
    enable = true;
    enable3G = false;
    enableCDMA = false;
    enableModemGPS = false;
    enableNmea = true;
    enableStatic = false;
    enableWifi = false;
    appConfig = {
      "geoclue-demo-agent" = {
        isAllowed = true;
        isSystem = true;
        users = [ ];
      };
      "geoclue-where-am-i" = {
        isAllowed = true;
        isSystem = false;
        users = [ ];
      };
      "firefox" = {
        isAllowed = true;
        isSystem = false;
        users = [ ];
      };
      # Chomium browsers don't use geoclue as geolocation source.
      # "google-chrome" = {
      #   isAllowed = true;
      #   isSystem = false;
      #   users = [ ];
      # };
      # "chromium" = {
      #   isAllowed = true;
      #   isSystem = false;
      #   users = [ ];
      # };
    };
  };

  # To provide fake location to geoclue via nmea-network, run following commands.
  # ```
  # # Send nmea data (must be in eigher GGA or RMC format) to the socket. The socket needs to be mode=666 because geoclue is run by "geoclue" user.
  # <nmea generator program> | sudo socat unix-listen:/var/run/gps-share.sock,fork,reuseaddr,mode=666 -
  # ```
  # To see if its working, run:
  # ```
  # /nix/store/xxx/libexec/geoclue-2.0/demos/where-am-i
  # ```

  environment.systemPackages = with pkgs; [ gpsd ];
}
