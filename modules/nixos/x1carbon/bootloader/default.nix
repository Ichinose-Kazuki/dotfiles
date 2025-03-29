{ inputs, pkgs, ... }:
{
  # TODO: Enable lanzaboote, set systemd-boot as default, set timeout to 0, and chainload grub...?
  # TODO: https://wiki.archlinux.org/title/Systemd-boot#GRUB
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 3;
    editor = false; # Recommended to set this to false.
    # https://github.com/Gerg-L/nixos/blob/3563e757eee5201420a8dc61a543a329f2bb08d7/hosts/gerg-desktop/boot.nix#L74
    extraFiles = {
      "shellx64.efi" = pkgs.edk2-uefi-shell.efi;
      # https://github.com/jordanisaacs/dotfiles/blob/4a779f42204c4fff743c12b26e28567eaf8cc334/overlays/default.nix#L6
      # https://github.com/jordanisaacs/dotfiles/blob/4a779f42204c4fff743c12b26e28567eaf8cc334/modules/system/boot/default.nix#L47
      "efi/efi-power/reboot.efi" = "${pkgs.efi-power}/reboot.efi";
      "efi/efi-power/poweroff.efi" = "${pkgs.efi-power}/poweroff.efi";
    };
    extraEntries = {
      # Sort-key is configured so that these come after the nixos entries (which have sort-key nixos).
      # Remove -noconsolein to be able to type any pins.
      "power.conf" = ''
        title Power Off
        sort-key z0
        efi /efi/efi-power/poweroff.efi
      '';
      "reboot.conf" = ''
        title Reboot
        sort-key z1
        efi /efi/efi-power/reboot.efi
      '';
      "windows.conf" = ''
        title Windows
        sort-key z2
        efi /shellx64.efi
        options -nointerrupt -noconsolein -noconsoleout HD0b:EFI\Microsoft\Boot\bootmgfw.efi
      '';
    };
  };
  boot.loader.efi.canTouchEfiVariables = true; # Required to write boot entry to NVRAM.
}
