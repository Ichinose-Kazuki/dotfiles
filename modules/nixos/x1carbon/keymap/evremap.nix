{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.evremap = {
    enable = true;
    settings = {
      device_name = "AT Translated Set 2 keyboard";
      # phys = "isa0060/serio0/input0"; # Laptop integrated keyboard.

      # "KEY_WAKEUP" is Fn key on ThinkPad.
      remap = [
        {
          input = [
            "KEY_WAKEUP"
            "KEY_H"
          ];
          output = [ "KEY_LEFT" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_J"
          ];
          output = [ "KEY_DOWN" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_K"
          ];
          output = [ "KEY_UP" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_L"
          ];
          output = [ "KEY_RIGHT" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_N"
          ];
          output = [ "KEY_HOME" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_M"
          ];
          output = [ "KEY_END" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_U"
          ];
          output = [ "KEY_PAGEUP" ];
        }

        {
          input = [
            "KEY_WAKEUP"
            "KEY_D"
          ];
          output = [ "KEY_PAGEDOWN" ];
        }
      ];
    };
  };
}
