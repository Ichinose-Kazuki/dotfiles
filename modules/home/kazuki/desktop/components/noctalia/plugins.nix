{
  pkgs,
  ...
}:

{
  # Installed plugins. Features built into the shell (the privacy widget, the
  # battery service, the polkit agent, and the fancy_audio_visualizer desktop
  # widget) need no entry here.
  programs.noctalia.settings.plugins = {
    auto_update = "none";
    enabled = [
      "noctalia/screen_recorder"
      "noctalia/timer"
      "noctalia/kaomoji"
      "alexander/screen-toolkit"
      "aristides/udiskie"
      "icefish/phone-connect"
      "rylos/tailnet"
      "nightwatch75/file-search"
    ];
  };

  # Per-plugin settings, keyed by plugin id; keys follow each plugin's
  # [[setting]] manifest.
  programs.noctalia.settings.plugin_settings = {
    "noctalia/screen_recorder" = {
      hide_inactive = true;
    };
    "aristides/udiskie" = {
      auto_open_filemanager = true;
      file_manager_cmd = "nemo";
    };
    "rylos/tailnet" = {
      hide_offline = true;
    };
    "nightwatch75/file-search" = {
      show_hidden = true;
    };
  };

  # The Udiskie plugin only observes events; auto-mount is provided by the
  # standalone udiskie daemon. Notifications come from the plugin, so the
  # daemon's are disabled and its tray icon is off.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = false;
    tray = "never";
  };

  home.packages = with pkgs; [
    # Screen recorder plugin.
    gpu-screen-recorder
    # Screen toolkit plugin.
    grim
    slurp
    wl-clipboard
    imagemagick
    zbar
    curl
    ffmpeg
    jq
    wl-screenrec
    translate-shell
    gifski
    # USB drive manager (udiskie) plugin.
    udisks
    # KDE Connect (phone-connect) plugin.
    sshfs
  ];

  services.kdeconnect.enable = true;
  programs.fd.enable = true;
}
