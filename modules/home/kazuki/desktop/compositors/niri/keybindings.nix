{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsbinds
  programs.niri.settings.binds =
    with config.lib.niri.actions;
    lib.mkMerge [
      {
        # pure niri, run `niri msg action help` to see all the actions
        "Mod+Shift+Q" = {
          action = close-window;
          repeat = false;
        };

        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+L".action = focus-column-right;

        "Mod+Shift+K".action = move-column-to-workspace-up;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-column-to-workspace-down;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Up".action = focus-monitor-up;
        "Mod+Left".action = focus-monitor-left;
        "Mod+Down".action = focus-monitor-down;
        "Mod+Right".action = focus-monitor-right;

        "Mod+Shift+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Right".action = move-column-to-monitor-right;

        # Tabbed display or vertical split
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;
        "Mod+T".action = toggle-column-tabbed-display;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-column-width-back;
        "Mod+W".action = maximize-column;
        "Mod+Shift+W".action = fullscreen-window; # Is toggle-windowed-fullscreen better?

        "Mod+O".action = toggle-overview;
      }

      {
        # noctalia
        # core & navigation
        "Mod+Space".action.spawn = noctalia "launcher toggle";
        "Super+V".action.spawn = noctalia "launcher clipboard";

        # system controls
        "XF86AudioLowerVolume" = {
          action.spawn = noctalia "volume decrease";
          allow-when-locked = true;
        };
        "XF86AudioRaiseVolume" = {
          action.spawn = noctalia "volume increase";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action.spawn = noctalia "volume muteOutput";
          allow-when-locked = true;
        };

        # interface & plugins
        "Super+L".action.spawn = noctalia "lockScreen lock";
      }

      {
        # spawn apps
        "Mod+Shift+T".action.spawn = "kitty";
        "Mod+Shift+E".action.spawn = "nemo";
        "Super+Shift+S".action.spawn = [
          "flameshot"
          "gui"
        ];
      }
    ];

  programs.niri.settings.input = {
    mod-key = "Alt";
    mod-key-nested = "Super";
  };
}
