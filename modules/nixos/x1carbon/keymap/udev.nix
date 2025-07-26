{ ... }:

{
  # https://bearmini.hatenablog.com/entry/2023/12/03/134330
  # https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
  # Comments are allowed only on the top level.
  services.udev.extraHwdb = ''
    # Disable PgUp(c9) and PgDn(d1) keys.
    # Change CapsLock(3a) to RightCtrl.
    # Change LeftCtrl(1d) to WakeUp(value mapped to fn key by default on ThinkPad).
    evdev:atkbd:*
      KEYBOARD_KEY_c9=reserved
      KEYBOARD_KEY_d1=reserved
      KEYBOARD_KEY_3a=rightctrl
      KEYBOARD_KEY_1d=wakeup
  '';
}
