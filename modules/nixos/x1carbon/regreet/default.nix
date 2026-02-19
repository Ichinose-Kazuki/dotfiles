{
  inputs,
  config,
  pkgs,
  ...
}:

{
  programs.regreet = {
    enable = true;
    cageArgs = [
      "-s"
      "-d"
      "-m"
      "last"
    ];
    theme = {
      package = pkgs.canta-theme;
      name = "";
    };
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
    };
  };

  environment.sessionVariables = {
    SESSION_DIRS = [
      "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
      "${config.services.displayManager.sessionData.desktops}/share/xsessions"
    ];
  };

  # fingerprint auth: https://sbulav.github.io/nix/nix-fingerprint-authentication/
}
