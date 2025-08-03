{ ... }:

{
  # https://bearmini.hatenablog.com/entry/2023/12/03/134330
  # https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
  # See modalias files for device matching strings. /sys/class/**/modalias
  # e.g. /sys/class/dmi/id/modalias
  # Comments are allowed only on the top level.
  services.udev.extraHwdb = ''
    # Disable PgUp(c9) and PgDn(d1) keys.
    # Change CapsLock(3a) to RightCtrl.
    # Change LeftCtrl(1d) to LeftAlt.
    # Change LeftAlt(38) to WakeUp(value mapped to fn key by default on ThinkPad).
    # For ThinkPad X1 Carbon Gen12 internal keyboard
    evdev:atkbd:*
      KEYBOARD_KEY_c9=reserved
      KEYBOARD_KEY_d1=reserved
      KEYBOARD_KEY_3a=rightctrl
      KEYBOARD_KEY_1d=leftalt
      KEYBOARD_KEY_38=wakeup
  '';
}
