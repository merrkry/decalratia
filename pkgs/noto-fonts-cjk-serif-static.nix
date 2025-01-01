{
  stdenvNoCC,
  fetchFromGitHub,
  nixosTests,
}:

stdenvNoCC.mkDerivation rec {
  pname = "noto-fonts-cjk-serif-static";
  version = "2.003";

  src = fetchFromGitHub {
    owner = "notofonts";
    repo = "noto-cjk";
    rev = "Serif${version}";
    hash = "sha256-mfbBSdJrUCZiUUmsmndtEW6H3z6KfBn+dEftBySf2j4=";
    sparseCheckout = [ "Serif/OTC" ];
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/noto-cjk Serif/OTC/*.ttc
  '';

  passthru.tests.noto-fonts = nixosTests.noto-fonts;
}
