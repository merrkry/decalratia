{ stdenvNoCC, fetchurl }:
stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "17.4";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/v${version}/AppleColorEmoji.ttf";
    hash = "sha256-SG3JQLybhY/fMX+XqmB/BKhQSBB0N1VRqa+H6laVUPE=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm444 $src $out/share/fonts/apple-color-emoji/apple-color-emoji.ttf
  '';
}
