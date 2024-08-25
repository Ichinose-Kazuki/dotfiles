{ lib, pkgs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # "settings" overwrites "/etc/sddm.conf".
    # Config: https://man.archlinux.org/man/sddm.conf.5
    settings = {
      Theme = {
        Current = "my-breeze-dark";
        CursorTheme = "breeze-dark";
      };
    };
  };

  # Avatar image (https://github.com/thomX75/nixos-modules/tree/main/SDDM)
  imports = [
    ./sddm-avatar.nix
    ./my-breeze-dark.nix
  ];
}
