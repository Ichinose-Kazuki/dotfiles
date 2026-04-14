# https://github.com/Hikiru/nix-config/blob/5b6d452431df423a47565c9ddcaaf98b5da11f37/derivations/niri-tile-to-n.nix#L35

{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:

let
  niri-tile-to-n = pkgs.stdenv.mkDerivation {
    pname = "niri-tile-to-n";
    version = "b9a8eca759f0788959cdcfa3ed2f49e7ce077e8b";

    src = pkgs.fetchFromGitHub {
      owner = "heyoeyo";
      repo = "niri_tweaks";
      rev = "b9a8eca759f0788959cdcfa3ed2f49e7ce077e8b";
      sha256 = "sha256-Tqg1lAcltrQAflap4Q0RMyYEQfO6TbSAuuOT93yzW7I=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.python3 ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp $src/niri_tile_to_n.py $out/bin/niri-tile-to-n
      chmod +x $out/bin/niri-tile-to-n

      # Ensure the script uses the correct Python interpreter
      substituteInPlace $out/bin/niri-tile-to-n \
        --replace "#!/usr/bin/env python3" "#!${pkgs.python3}/bin/python3"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Auto-tiler script for niri window manager";
      homepage = "https://github.com/heyoeyo/niri_tweaks";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.linux;
      mainProgram = "niri-tile-to-n";
    };
  };
in
{
  systemd.user.services.niri-tile-to-n = {
    Unit = {
      Description = "niri-tile-to-n";
      Documentation = "https://github.com/heyoeyo/niri_tweaks";
      PartOf = [ config.wayland.systemd.target ];
      After = [ config.wayland.systemd.target ];
    };

    Service = {
      ExecStart = "${lib.getExe niri-tile-to-n} -n 2";
      Restart = "on-failure";
    };

    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  home.packages = with pkgs; [
    niri-tile-to-n
  ];
}
