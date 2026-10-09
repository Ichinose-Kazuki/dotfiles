{
  pkgs,
  ...
}:

{
  # v5 plugins replace the v4 QML plugins. The v4 set is no longer compatible,
  # so each is mapped to a built-in feature, an official plugin, or a community
  # plugin (see the migration notes). Built-in replacements need no entry here:
  # privacy -> the privacy widget, audio visualizer -> fancy_audio_visualizer,
  # battery -> the battery widget/service, polkit -> shell.polkit_agent.
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

  # Plugin settings, ported from the v4 plugin settings. Keys follow each v5
  # plugin's [[setting]] manifest.
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

  # The community Udiskie plugin only observes events (via udisksctl); it does
  # not auto-mount. The previous auto-mount behavior is restored with the
  # standalone udiskie daemon. Notifications are left to the plugin to avoid
  # duplicates, and the tray icon is disabled.
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
