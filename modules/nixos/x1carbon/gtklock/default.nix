{
  inputs,
  config,
  pkgs,
  ...
}:

{
  programs.gtklock = {
    enable = true;
    config = {
      main = {
        idle-hide = true;
        idle-timeout = 10;
      };
    };
    modules = with pkgs; [
      gtklock-playerctl-module
      gtklock-powerbar-module
      gtklock-userinfo-module
    ];
    style = ''
      window {
         background-size: cover;
         background-repeat: no-repeat;
         background-position: center;
         background-color: black;
      }
    '';
  };

  security.pam.services.gtklock = {
    # unlock kwallet upon unlocking lockscreen.
    kwallet = {
      enable = true;
    };
  };
}
