{ pkgs, lib, config, ... }:

{
  config = lib.mkIf (builtins.elem "kdePlasma" config.myModule.desktop.components) {
    environment.systemPackages = with pkgs; [
      kdePackages.kate
      kdePackages.kwallet-pam
      kdePackages.kwallet
      kdePackages.sddm-kcm
    ];
  };
}
