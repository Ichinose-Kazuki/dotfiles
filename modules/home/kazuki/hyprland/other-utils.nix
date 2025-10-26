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
    # terminal theme
    kitty-themes
    # file manager
    # installs folder-color-switcher, nemo-emblems, nemo-fileroller, nemo-python by default.
    (nemo-with-extensions.override { extensions = [ nemo-preview ]; })
    gnome-font-viewer
    p7zip-rar # for encrypted archives
    zip
    unzip
    webp-pixbuf-loader # for webp thumbnails
    # networkmanager gui
    networkmanagerapplet
  ];

  # status bar
  my-waybar.enable = true;

  # app launcher
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    cycle = true;
    modes = [
      "combi"
      "emoji" # not working on electron
    ];
    terminal = "kitty";
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
  programs.kitty = {
    enable = true;
    shellIntegration = {
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    enableGitIntegration = true;
    # Mappable actions: https://sw.kovidgoyal.net/kitty/actions
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+equal" = "change_font_size all +2.0";
      "ctrl+minus" = "change_font_size all -2.0";
    };
    # About kitty.conf: https://sw.kovidgoyal.net/kitty/conf
    settings = {
      tab_bar_edge = "top";
      tab_bar_min_tabs = 1;
      window_padding_width = "5 5";
    };
    # run "kitten themes" to preview all themes.
    themeFile = "Chalk"; # afterglow, bluloco dark, broadcast, chalk,
  };
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

  # file manager

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
  # not using nixos side option because waybar doesn't show the indicator.
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
      ExecStart = "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator";
      Restart = "on-failure";
    };
  };

  # blueman applet for bluetooth
  services.blueman-applet.enable = true;
}
