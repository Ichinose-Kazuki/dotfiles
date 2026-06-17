{ lib, pkgs, config, ... }:

{
  config = lib.mkIf (config.myModule.desktop.displayManager == "sddm") {
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
  };
}
