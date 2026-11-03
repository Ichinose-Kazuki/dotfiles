{
  pkgs,
  lib,
  config,
  ...
}:

let
  noctaliaBin = lib.getExe' config.programs.noctalia.package "noctalia";

  # Noctalia's caffeine inhibitor suppresses idle notifications, so swayidle
  # cannot turn the screen off while it is active. Disable caffeine when the
  # session locks, then restore it on unlock, but only if it was on before.
  #
  # Noctalia registers caffeine as a logind idle inhibitor, which lets the lock
  # hook read the previous state without touching the caffeine UI. The marker
  # lives in the session runtime directory so it survives suspend but is
  # cleared on logout or reboot.
  mkHook =
    action:
    pkgs.writeShellApplication {
      name = "noctalia-caffeine-${action}";
      runtimeInputs = with pkgs; [
        systemd
        gawk
        coreutils
      ];
      text =
        if action == "lock" then
          ''
            marker="''${XDG_RUNTIME_DIR:?}/noctalia-caffeine-paused"

            if systemd-inhibit --list --no-pager --no-legend |
              awk '$1 == "noctalia" && $6 == "idle" && $7 == "Caffeine" { found = 1 } END { exit !found }'
            then
              : > "$marker"
              ${noctaliaBin} msg caffeine-disable >/dev/null 2>&1 || true
            fi
          ''
        else
          ''
            marker="''${XDG_RUNTIME_DIR:?}/noctalia-caffeine-paused"

            if [ -e "$marker" ]; then
              rm -f "$marker"
              ${noctaliaBin} msg caffeine-enable >/dev/null 2>&1 || true
            fi
          '';
    };

  lockHook = mkHook "lock";
  unlockHook = mkHook "unlock";
in
{
  # swayidle's lock/unlock events are logind Lock/Unlock signals and do not
  # fire for Noctalia's lock screen, so use Noctalia's own hooks here.
  programs.noctalia.settings.hooks = {
    session_locked = [ "${lockHook}/bin/noctalia-caffeine-lock" ];
    session_unlocked = [ "${unlockHook}/bin/noctalia-caffeine-unlock" ];
  };
}
