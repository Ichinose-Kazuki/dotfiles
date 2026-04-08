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
        # pure niri, run `niri msg action` to see all the actions
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

        "Mod+D".action = focus-monitor-up;
        "Mod+A".action = focus-monitor-left;
        "Mod+S".action = focus-monitor-down;
        "Mod+F".action = focus-monitor-right;

        "Mod+Shift+D".action = move-column-to-monitor-up;
        "Mod+Shift+A".action = move-column-to-monitor-left;
        "Mod+Shift+S".action = move-column-to-monitor-down;
        "Mod+Shift+F".action = move-column-to-monitor-right;

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
      }
    ];

  programs.niri.settings.input = {
    mod-key = "Alt";
    mod-key-nested = "Super";
  };
}
