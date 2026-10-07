{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    kdePackages.kwallet-pam
    kdePackages.kwallet
    kdePackages.sddm-kcm
  ];
}
