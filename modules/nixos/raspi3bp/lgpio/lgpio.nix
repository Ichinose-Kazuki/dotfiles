# https://github.com/jhakonen/nixos-config/blob/c4d98d1b3310e23ffeaeebc6b2546ded8b9ef942/packages/nix/lgpio.nix#L5

{ stdenv, fetchFromGitHub, which }:

stdenv.mkDerivation {
  name = "lgpio";
  version = "v0.2.2";
  src = fetchFromGitHub {
    owner = "joan2937";
    repo = "lg";
    rev = "v0.2.2";
    sha256 = "sha256-92lLV+EMuJj4Ul89KIFHkpPxVMr/VvKGEocYSW2tFiE=";
  };
  buildInputs = [ which ];
  installFlags = [ "DESTDIR=${placeholder "out"}" "prefix=" ];
}
