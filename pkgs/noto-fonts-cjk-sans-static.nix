{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nixosTests,
}:

stdenvNoCC.mkDerivation rec {
  pname = "noto-fonts-cjk-sans-static";
  version = "2.004";

  src = fetchFromGitHub {
    owner = "notofonts";
    repo = "noto-cjk";
    rev = "Sans${version}";
    hash = "sha256-GXULnRPsIJRdiL3LdFtHbqTqSvegY2zodBxFm4P55to=";
    sparseCheckout = [ "Sans/OTC" ];
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-cjk Sans/OTC/*.ttc
  '';

  passthru.tests.noto-fonts = nixosTests.noto-fonts;
}
