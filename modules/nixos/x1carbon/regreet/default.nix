{ inputs, pkgs, ... }:

{
  programs.regreet = {
    enable = true;
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

  # fingerprint auth: https://sbulav.github.io/nix/nix-fingerprint-authentication/
}
