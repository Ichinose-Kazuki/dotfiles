{
  environment.systemPackages = with pkgs; [
    kdePackages.sddm-kcm
    kdePackages.kwallet-pam
    kdePackages.kwallet
  ];
}
