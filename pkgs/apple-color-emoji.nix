{
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "apple-color-emoji";
  version = "0-unstable-2026-03-18";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260219-2aa12422/AppleColorEmoji-Linux.ttf";
    hash = "sha256-U1oEOvBHBtJEcQWeZHRb/IDWYXraLuo0NdxWINwPUxg=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src "$out/share/fonts/apple-color-emoji/apple-color-emoji.ttf"
  '';
}
