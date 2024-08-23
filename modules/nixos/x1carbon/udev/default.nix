{
  # Comments are allowed only on the top level.
  services.udev.extraHwdb = ''
    # Disable PgUp(c9) and PgDn(d1) keys.
    # Change CapsLock to Ctrl.
    evdev:atkbd:*
      KEYBOARD_KEY_c9=reserved
      KEYBOARD_KEY_d1=reserved
      KEYBOARD_KEY_3a=leftctrl
  '';
}
