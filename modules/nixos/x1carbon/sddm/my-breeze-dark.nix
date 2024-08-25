# Modified code from https://github.com/thomX75/nixos-modules

{ pkgs, ... }:

let

  my-breeze-dark = pkgs.stdenv.mkDerivation rec {
    pname = "my-breeze-dark";
    version = "1.0.0";
    src = pkgs.kdePackages.plasma-desktop;

    installPhase = ''
      mkdir -p $out/share/sddm/themes/my-breeze-dark
      cp -r $src/share/sddm/themes/breeze/* $out/share/sddm/themes/my-breeze-dark

      chmod 766 $out/share/sddm/themes/my-breeze-dark/theme.conf

      sed -i 's|^background=.*|background=${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/MilkyWay/contents/images/5120x2880.png|' $out/share/sddm/themes/my-breeze-dark/theme.conf

      chmod 644 $out/share/sddm/themes/my-breeze-dark/theme.conf
    '';

    meta = with pkgs.lib; {
      description = "My Breeze Dark theme";
      homepage = "";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

in

{
  environment.systemPackages = with pkgs; [ my-breeze-dark ];
}
