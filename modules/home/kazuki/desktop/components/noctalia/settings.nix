{
  ...
}:

{
  # Migrated from the v4 settings.json. Only values that differ from the v5
  # defaults are set here; everything else falls back to Noctalia's defaults.
  programs.noctalia.settings = {
    bar.default = {
      position = "top";
      start = [
        "workspaces"
        "active_window"
        "media"
      ];
      center = [
        "clock"
      ];
      end = [
        "tray"
        "notifications"
        "battery"
        "volume"
        "brightness"
        "control-center"
      ];
      background_opacity = 0.93;
      capsule = true;
      margin_ends = 4;
      radius = 12;
    };

    widget.clock = {
      type = "clock";
      format = "{:%Y/%m/%d %H:%M}";
    };

    # v4 privacy-indicator (hideInactive) is now a built-in widget setting.
    widget.privacy = {
      type = "privacy";
      hide_inactive = true;
    };

    theme = {
      mode = "dark";
      source = "custom";
      custom_palette = "kazuki";
    };

    audio = {
      enable_overdrive = false;
      enable_sounds = false;
    };

    battery.warning_threshold = 20;

    lockscreen = {
      enabled = true;
      fingerprint = true;
      lock_before_suspend = true;
    };

    nightlight.enabled = true;

    desktop_widgets.enabled = false;

    dock = {
      enabled = true;
      auto_hide = true;
      position = "bottom";
    };

    notification = {
      background_opacity = 1.0;
      position = "top_right";
    };

    osd = {
      enabled = true;
      hide_delay_ms = 2000;
      position = "top_right";
    };

    keybinds = {
      up = [ "Up" ];
      down = [ "Down" ];
      left = [ "Left" ];
      right = [ "Right" ];
      validate = [
        "Return"
        "Enter"
      ];
      cancel = [ "Escape" ];
      delete = [ "Delete" ];
    };

    location = {
      address = "Tokyo";
      auto_locate = false;
    };

    weather = {
      enabled = true;
      effects = true;
      unit = "metric";
    };

    control_center = {
      calendar.show_events_card = true;
      shortcuts = [
        { type = "wifi"; }
        { type = "bluetooth"; }
        { type = "wallpaper"; }
        { type = "notification"; }
        { type = "power_profile"; }
        { type = "caffeine"; }
        { type = "nightlight"; }
      ];
    };

    shell = {
      polkit_agent = true;
      clipboard_enabled = true;
      telemetry_enabled = false;
      mpris.blacklist = [ ];
      session = {
        show_shortcuts = true;
        actions = [
          {
            action = "lock";
            shortcut = "1";
          }
          {
            action = "logout";
            shortcut = "2";
          }
          {
            action = "lock_and_suspend";
            shortcut = "3";
          }
          {
            action = "reboot";
            shortcut = "4";
          }
          {
            action = "shutdown";
            shortcut = "5";
            variant = "destructive";
          }
        ];
      };
    };

    system.monitor = {
      cpu_temp_activity_threshold = 80.0;
      cpu_temp_critical_threshold = 90.0;
      cpu_usage_activity_threshold = 80.0;
      cpu_usage_critical_threshold = 90.0;
      disk_used_pct_activity_threshold = 80.0;
      disk_used_pct_critical_threshold = 90.0;
      ram_pct_activity_threshold = 80.0;
      ram_pct_critical_threshold = 90.0;
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      transition_duration = 1500.0;
      transition_on_startup = false;
    };
  };
}
