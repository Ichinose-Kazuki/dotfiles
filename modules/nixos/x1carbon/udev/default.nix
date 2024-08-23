{
  services.udev.extraHwdb = ''
    evdev:atkbd:*
    # Disable PgUp(c9) and PgDn(d1) keys.
    KEYBOARD_KEY_c9=reserved
    KEYBOARD_KEY_d1=reserved
    # Change CapsLock to Ctrl.
    KEYBOARD_KEY_3a=leftctrl
  '';
}
