{
  config,
  pkgs,
  lib,
  ...
}:

let
  remotely-save-pkg = pkgs.stdenv.mkDerivation rec {
    pname = "removely-save";
    version = "0.5.25";

    src_main = pkgs.fetchurl {
      url = "https://github.com/remotely-save/remotely-save/releases/download/${version}/main.js";
      sha256 = "sha256-s6+9J/FRiLl4RhjJWGB4abqkNNwKvPByd0+ZNiwR+gQ=";
    };

    src_manifest = pkgs.fetchurl {
      url = "https://github.com/remotely-save/remotely-save/releases/download/${version}/manifest.json";
      sha256 = "sha256-cdnAthYAPzppaIDnqogpblsxVVdX6TOhLSkAuWxMqpA=";
    };

    src_styles = pkgs.fetchurl {
      url = "https://github.com/remotely-save/remotely-save/releases/download/${version}/styles.css";
      sha256 = "sha256-h1hOfVOMpYxSevuyYlsJ6igryue/eEt8zjPKkung37M=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out
      cp ${src_main} $out/main.js
      cp ${src_manifest} $out/manifest.json
      cp ${src_styles} $out/styles.css
      echo "data.json" > $out/.gitignore
    '';
  };
in
{
  # Uses internal OneDrive client
  programs.obsidian.defaultSettings.communityPlugins = [
    {
      enable = true;
      pkg = remotely-save-pkg;
      # Can't write settings here bc it contains OneDrive auth info.
    }
  ];
}
