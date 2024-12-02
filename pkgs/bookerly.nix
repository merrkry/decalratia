{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation {
  pname = "bookerly";
  version = "2020.03";

  src = fetchzip {
    url = "https://m.media-amazon.com/images/G/01/mobile-apps/dex/alexa/branding/Amazon_Typefaces_Complete_Font_Set_Mar2020.zip";
    hash = "sha256-CK7WSXkJkcwMxwdeW31Zs7p2VdZeC3xbpOnmd6Rr9go=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype/ Bookerly/*.ttf
    install -Dm644 -t $out/share/fonts/truetype/ Bookerly\ Display/*.ttf

    runHook postInstall
  '';
}
