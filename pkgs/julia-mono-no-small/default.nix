{
  lib,
  stdenv,
  fetchurl,
  julia-mono,
  python3,
}:

let
  version = "0.63.2";

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/cormullion/juliamono/v${version}/LICENSE";
    hash = "sha256-uuO+/54V8aaAwnZMS72yW5lbm/U5rq+EZ0gqSVx1rQw=";
  };

  python = python3.withPackages (ps: [ ps.fonttools ]);
in
stdenv.mkDerivation {
  pname = "julia-mono-no-small";
  inherit version;

  nativeBuildInputs = [ python ];
  buildInputs = [ julia-mono ];

  # The inputs are copied individually, so there is nothing to unpack.
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    cp ${julia-mono}/share/fonts/truetype/JuliaMono-*.ttf build/
    python3 ${./filter_fonts.py} build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -d $out/share/fonts/truetype/no-small-mono
    install -m444 build/JuliaNoSmallMono-*.ttf $out/share/fonts/truetype/no-small-mono/
    install -m444 -D ${licenseFile} $out/share/licenses/julia-mono-no-small/LICENSE
    runHook postInstall
  '';

  meta = {
    description = "JuliaMono with small enclosed alphanumeric glyphs removed";
    homepage = "https://github.com/cormullion/juliamono";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
