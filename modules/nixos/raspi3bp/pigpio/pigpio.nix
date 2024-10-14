{ stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation {
  pname = "pigpio";
  version = "79";
  src = fetchFromGitHub {
    owner  = "joan2937";
    repo   = "pigpio";
    rev    = "c33738a320a3e28824af7807edafda440952c05d";
    sha256 = "0wgcy9jvd659s66khrrp5qlhhy27464d1pildrknpdava19b1r37";
  };
  buildInputs = [cmake];
}
