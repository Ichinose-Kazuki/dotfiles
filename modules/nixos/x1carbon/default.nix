{ ... }:

{
  imports = [
    ./boot
    ./bootloader
    ./docker
    ../files
    ./gaming
    ./gtklock
    ./keymap
    ./location
    # ./ly
    ./niri
    ./noctalia-plugin-dep
    ./power
    ./printing
    ./programs
    ./regreet
    # ./sddm
    ./sound
    ./ssh
    # ./sway
    ./waydroid
    # ./wayland
    ./wtfutil
    ../keyboard
    ../keyring
    ../common/tailscale
    ../system-components/battery
  ];
}
