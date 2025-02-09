{ stdenvNoCC, fetchFromGitHub }:
stdenvNoCC.mkDerivation {
  pname = "apple-system-fonts";
  version = "0-unstable-2024-02-08";

  src = fetchFromGitHub {
    owner = "merrkry";
    repo = "BlinkMacSystemFont";
    rev = "401da13240db729268c7c8c59449debcf1bddd78";
    hash = "sha256-zM8SWMcqCYBTz+Uy/bcao6uhXwQdw+fzFGF5PoQpoEg=";
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/apple-system-fonts $src/otf/*.otf
  '';
}
