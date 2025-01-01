{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "memogram";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "usememos";
    repo = "telegram-integration";
    rev = "v${version}";
    hash = "sha256-24LgBLbbde6kQaYesA2rbFXBGLyoQ9DfDGsDMH3beos=";
  };

  vendorHash = "sha256-7GcEbtt/5a0mA90Ailwo7tKctsZEASKyO44Vd19XIfI=";

  subPackages = [ "bin/memogram" ];
}
