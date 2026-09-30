{
  config,
  pkgs,
  lib,
  ...
}:

{
  # config.txt generator from nixos-hardware:
  # https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/README.md#configtxt
  # default values:
  # https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/common/config-txt-defaults.nix
  # https://github.com/NixOS/nixos-hardware/blob/master/raspberry-pi/common/firmware.nix#L182
  hardware.raspberry-pi.configtxt.settings = {

    # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters
    all = {

      # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
      # when attempting to show low-voltage or overtemperature warnings.
      avoid_warnings = true;

      # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
      # in conjunction with `console=serial0,115200` in kernel command line (`cmdline.txt`)
      # creates a serial console, accessible using GPIOs 14 and 15 (pins
      #  8 and 10 on the 40-pin header)
      # enable_uart = true; # TODO: test U-Boot interaction

      # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
      # enable debug logging to the UART, also automatically enables
      # UART logging in `start.elf`
      # uart_2ndstage = true;

      # Base DTB parameters
      # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
      dt-param = [

        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
        "pciex1=on"

        # PCIe Gen 3.0
        # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
        "pciex1_gen=3"
      ];
    };
  };
}
