{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "memogram";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "usememos";
    repo = "telegram-integration";
    rev = "v${version}";
    hash = "sha256-dV3Mdxts1mHCHl2AIdD037Y/GGrfykTHNmfQCh6W76s=";
  };

  vendorHash = "sha256-ZbYMd4uv6KnegCdrXfaYBaZJSbJiYV2rdAzlBf3E7ew=";

  subPackages = [ "bin/memogram" ];
}
