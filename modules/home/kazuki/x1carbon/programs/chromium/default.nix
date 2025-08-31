{
  config,
  pkgs,
  ...
}:

{
  # home.file."${config.xdg.dataHome}/applications/google-chrome.desktop".source = ./google-chrome.desktop;
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      # https://wiki.archlinux.org/title/Chromium#Native_Wayland_support
      # args listed in the above article are automatically set when "NIXOS_OZONE_WL=1".
    ];
    package = pkgs.google-chrome;
  };

  home.packages = with pkgs; [
    ocs-url
  ];
}
