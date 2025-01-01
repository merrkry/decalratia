{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "kvlibadwaita-kvantum";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "GabePoel";
    repo = "KvLibadwaita";
    rev = "3deb8dbe5f6f0826e9934988ab9225951db651e8";
    sha256 = "sha256-M0XhmZ/2lk+6jIkUxAog1A+/BIz9/mUTeWGV1mtBrxY=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/Kvantum
    cp -a src/KvLibadwaita $out/share/Kvantum
    runHook postInstall
  '';
}
