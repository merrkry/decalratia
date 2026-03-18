{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "kvlibadwaita-kvantum";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvLibadwaita";
    rev = "1f4e0bec44b13dabfa1fe4047aa8eeaccf2f3557";
    hash = "sha256-jCXME6mpqqWd7gWReT04a//2O83VQcOaqIIXa+Frntc=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -a src/KvLibadwaita $out/share/Kvantum
    runHook postInstall
  '';
}
