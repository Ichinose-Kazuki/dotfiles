{ pkgs, ... }:

let
  # Patch to add 512 to the GPIO number
  # https://sourceforge.net/p/raspberry-gpio-python/tickets/210/#4ed1
  rpi-gpio-patched = pkgs.python312Packages.rpi-gpio.overrideAttrs {
    patches = [ ./gpio.add_512.patch ];
  };
in
{
  environment.systemPackages = with pkgs; [
    (python312.withPackages
      (_: [
        rpi-gpio-patched
      ]))
  ];
}
