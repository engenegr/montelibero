{ callPackage, fetchurl }:

let
  mkFlutter = opts: callPackage (import ./flutter.nix opts) { };
  getPatches = dir:
    let files = builtins.attrNames (builtins.readDir dir);
    in map (f: dir + ("/" + f)) files;
in {
  mkFlutter = mkFlutter;
  dev = mkFlutter rec {
    pname = "flutter";
    channel = "beta";
    version = "2.11.0-0.1.pre";
    filename = "flutter_linux_${version}-${channel}.tar.xz";
    sha256Hash = "sha256-vsEFnnawjI4IPKEwUSWZQmWnA3wJ/p5kx1Frmesu2Pk=";
    patches = getPatches ./patches/dev;
  };
}
