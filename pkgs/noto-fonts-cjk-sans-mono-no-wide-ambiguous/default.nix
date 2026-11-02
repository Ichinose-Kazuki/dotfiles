{
  lib,
  stdenv,
  fetchurl,
  python3,
}:

let
  version = "2.004";
  rev = "523d033d6cb47f4a80c58a35753646f5c3608a78";
  sourceUrl = "https://raw.githubusercontent.com/notofonts/noto-cjk/${rev}/Sans/Mono";

  sources = {
    regular = fetchurl {
      url = "${sourceUrl}/NotoSansMonoCJKjp-Regular.otf";
      hash = "sha256-TQFyW+gi0UTPmlat6YHm+5IM16YQuPwkzGAakgvupbk=";
    };
    bold = fetchurl {
      url = "${sourceUrl}/NotoSansMonoCJKjp-Bold.otf";
      hash = "sha256-39/+FJvGy/UoYNq9i42tvKQK6HpPvhQ7VcAljbLa37g=";
    };
  };

  licenseFile = fetchurl {
    url = "https://raw.githubusercontent.com/notofonts/noto-cjk/${rev}/LICENSE";
    hash = "sha256-anP5VBwt50FYwOfPawpY73dPWngL8ZHy1+ycxT7+K/I=";
  };

  python = python3.withPackages (ps: [ ps.fonttools ]);
in
stdenv.mkDerivation {
  pname = "noto-fonts-cjk-sans-mono-no-wide-ambiguous";
  inherit version;

  nativeBuildInputs = [ python ];

  # The inputs are fetched individually, so there is nothing to unpack.
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    mkdir -p build
    install -m444 ${sources.regular} build/NotoSansMonoCJKjp-Regular.otf
    install -m444 ${sources.bold} build/NotoSansMonoCJKjp-Bold.otf
    python3 ${./filter_fonts.py} build build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -m444 -D build/NotoSansMonoCJKjp-Regular-NoWideAmbiguous.otf \
      $out/share/fonts/opentype/noto-cjk-mono-no-wide-ambiguous/NotoSansMonoCJKjp-Regular-NoWideAmbiguous.otf
    install -m444 -D build/NotoSansMonoCJKjp-Bold-NoWideAmbiguous.otf \
      $out/share/fonts/opentype/noto-cjk-mono-no-wide-ambiguous/NotoSansMonoCJKjp-Bold-NoWideAmbiguous.otf
    install -m444 -D ${licenseFile} \
      $out/share/licenses/noto-fonts-cjk-sans-mono-no-wide-ambiguous/LICENSE
    runHook postInstall
  '';

  meta = {
    description = "Noto Sans Mono CJK JP with full-width East Asian Ambiguous characters removed";
    homepage = "https://github.com/notofonts/noto-cjk";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
