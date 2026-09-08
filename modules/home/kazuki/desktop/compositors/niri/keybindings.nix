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
  mod = "Super";
  subMod = "Alt";
in
{
  # options: https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsbinds
  programs.niri.settings.binds =
    with config.lib.niri.actions;
    lib.mkMerge [
      {
        # pure niri, run `niri msg action help` to see all the actions
        "${mod}+Shift+Q" = {
          action = close-window;
          repeat = false;
        };

        "${mod}+K".action = focus-window-or-workspace-up;
        "${mod}+H".action = focus-column-left;
        "${mod}+J".action = focus-window-or-workspace-down;
        "${mod}+L".action = focus-column-right;

        "${mod}+Shift+K".action = move-column-to-workspace-up;
        "${mod}+Shift+H".action = move-column-left;
        "${mod}+Shift+J".action = move-column-to-workspace-down;
        "${mod}+Shift+L".action = move-column-right;

        # "".action = focus-monitor-up;
        "${mod}+N".action = focus-monitor-left;
        # "".action = focus-monitor-down;
        "${mod}+M".action = focus-monitor-right;

        # "".action = move-column-to-monitor-up;
        "${mod}+Shift+N".action = move-column-to-monitor-left;
        # "".action = move-column-to-monitor-down;
        "${mod}+Shift+M".action = move-column-to-monitor-right;

        # Tabbed display or vertical split
        "${mod}+Comma".action = consume-window-into-column;
        "${mod}+Period".action = expel-window-from-column;
        "${mod}+T".action = toggle-column-tabbed-display;

        "${mod}+R".action = switch-preset-column-width;
        "${mod}+Shift+R".action = switch-preset-column-width-back;
        "${mod}+W".action = maximize-column;
        "${mod}+Shift+W".action = fullscreen-window; # Is toggle-windowed-fullscreen better?

        "${mod}+O".action = toggle-overview;
      }

      {
        # noctalia
        # core & navigation
        "${mod}+Space".action.spawn = noctalia "launcher toggle";
        "${mod}+${subMod}+V".action.spawn = noctalia "launcher clipboard";

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
        "${mod}+${subMod}+L".action.spawn = noctalia "lockScreen lock";
      }

      {
        # spawn apps
        "${mod}+Shift+T".action.spawn = "ghostty";
        "${mod}+Shift+E".action.spawn = "nemo";
        "${mod}+Shift+S".action.spawn = [
          "flameshot"
          "gui"
        ];
      }
    ];
}
