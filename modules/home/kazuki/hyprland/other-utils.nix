{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:

{
  imports = [
    # app launcher
    ./waybar
  ];

  home.packages = with pkgs; [
    # status bar
    font-awesome
    roboto
    # terminal
    kdePackages.konsole
    # file manager
    kdePackages.dolphin
    # networkmanager gui
    networkmanagerapplet
    kdePackages.kwallet
    gcr
  ];

  # status bar
  my-waybar.enable = true;

  # app launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    cycle = true;
    modes = [
      "combi"
      "emoji" # not working on electron
    ];
    # terminal = "kitty";
    extraConfig = {
      # run rofi -h to see all options
      combi-modi = [
        "drun"
        "run"
      ];
      combi-display-format = "{text} {mode}";
      show-icons = true;
      steal-focus = true;
      window-thumbnail = true;
      click-to-exit = true; # not working
      global-kb = true; # not working
    };
    theme = "Arc-Dark";
    plugins = with pkgs; [
      rofi-emoji
    ];
  };

  # terminal
  xdg.dataFile."defined_with_nix.profile".text = ''
    [Appearance]
    Font=Hack Nerd Font,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

    [General]
    Name=defined_with_nix
    Parent=FALLBACK/
  '';
  xdg.configFile."konsolerc".text = ''
    [Desktop Entry]
    DefaultProfile=defined_with_nix.profile

    [General]
    ConfigVersion=1

    [UiSettings]
    ColorScheme=Breeze Dark
  '';

  # file explorer
  xdg.configFile."dolphinrc".text = ''
    [General]
    Version=202
    ViewPropsTimestamp=2025,6,20,0,35,28.437

    [KFileDialog Settings]
    Places Icons Auto-resize=false
    Places Icons Static Size=22

    [MainWindow]
    MenuBar=Disabled

    [UiSettings]
    ColorScheme=Breeze Dark
  '';

  # nm-applet for wifi
  systemd.user.services.nm-applet = {
    Install = {
      WantedBy = [ config.wayland.systemd.target ];
    };

    Unit = {
      Description = "Network manager applet";
      After = [ config.wayland.systemd.target ];
      PartOf = [ config.wayland.systemd.target ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator";
      Restart = "on-failure";
    };
  };
  dbus.packages = with pkgs; [
    gcr
    kdePackages.kwallet
  ];

  # blueman applet for bluetooth
  services.blueman-applet.enable = true;
}
