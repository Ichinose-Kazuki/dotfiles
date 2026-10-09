{
  ...
}:

{
  # Only values that differ from the Noctalia defaults are set; everything else
  # falls back to the built-in defaults.
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
      # v4's default-density bar is 31px tall with 2px content padding.
      thickness = 31;
      padding = 2;
      capsule = true;
      # A full-length bar (margin_ends = 0) lets concave_edge_corners carve the
      # bottom corners, so the bar wraps the top of the windows. The corners on
      # the screen edge stay square, as in v4.
      margin_ends = 0;
      radius = 20;
      radius_top_left = 0;
      radius_top_right = 0;
      # There is no single shadow toggle, so each shadow surface is disabled.
      shadow = false;
    };

    widget.clock = {
      type = "clock";
      format = "{:%Y/%m/%d %H:%M}";
      tooltip_format = "";
      vertical_format = "";
    };

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
      # An empty transition pool disables the animated unlock.
      transition = [ ];
    };

    nightlight.enabled = true;

    desktop_widgets.enabled = false;

    dock = {
      enabled = true;
      auto_hide = true;
      # An auto-hidden dock overlays instead of reserving a compositor exclusive
      # zone, which would otherwise leave a blank strip below windows.
      reserve_space = false;
      position = "bottom";
      background_opacity = 1.0;
      # v4's dock was a floating dock, inset from the screen edge.
      margin_edge = 13;
      shadow = false;
    };

    notification = {
      background_opacity = 1.0;
      # v4 drew notifications on the overlay layer.
      layer = "overlay";
      position = "top_right";
    };

    osd = {
      enabled = true;
      background_opacity = 1.0;
      hide_delay_ms = 2000;
      position = "top_right";
      kinds.brightness = false;
      # Do not show an on-screen display when the input method changes.
      kinds.keyboard_layout = false;
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

    # Explicit sunrise/sunset drive the night-light window and theme auto mode.
    location = {
      auto_locate = true;
      custom_schedule = true;
      sunrise = "07:00";
      sunset = "23:00";
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
      # v4 disabled every shadow; v5 exposes them per surface.
      popup_shadows = false;
      panel.shadow = false;
      mpris.blacklist = [ ];
      session = {
        show_shortcuts = true;
        # hibernate and reboot-to-UEFI have no built-in action, so they use the
        # generic command action.
        actions = [
          {
            action = "lock";
            shortcut = "1";
          }
          {
            action = "suspend";
            shortcut = "2";
          }
          {
            action = "command";
            command = "systemctl hibernate";
            glyph = "hibernate";
            label = "Hibernate";
            shortcut = "3";
          }
          {
            action = "reboot";
            shortcut = "4";
          }
          {
            action = "logout";
            shortcut = "5";
          }
          {
            action = "shutdown";
            shortcut = "6";
            variant = "destructive";
          }
          {
            action = "command";
            command = "systemctl reboot --firmware-setup";
            glyph = "refresh";
            label = "Reboot to UEFI";
            shortcut = "7";
          }
        ];
      };
    };

    # Noctalia's per-metric defaults differ, so pin every threshold to 80/90.
    system.monitor = {
      cpu_temp_activity_threshold = 80.0;
      cpu_temp_critical_threshold = 90.0;
      cpu_usage_activity_threshold = 80.0;
      cpu_usage_critical_threshold = 90.0;
      disk_used_pct_activity_threshold = 80.0;
      disk_used_pct_critical_threshold = 90.0;
      gpu_temp_activity_threshold = 80.0;
      gpu_temp_critical_threshold = 90.0;
      gpu_usage_activity_threshold = 80.0;
      gpu_usage_critical_threshold = 90.0;
      ram_pct_activity_threshold = 80.0;
      ram_pct_critical_threshold = 90.0;
      swap_pct_activity_threshold = 80.0;
      swap_pct_critical_threshold = 90.0;
    };

    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      transition_duration = 1500.0;
      transition_on_startup = false;
    };
  };
}
