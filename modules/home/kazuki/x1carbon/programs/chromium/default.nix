{ config
, pkgs
, ...
}:

{
  # home.file."${config.xdg.dataHome}/applications/google-chrome.desktop".source = ./google-chrome.desktop;
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--enable-wayland-ime"
    ];
    package = pkgs.google-chrome;
  };

  home.packages = with pkgs; [
    ocs-url
  ];
}
