{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "deeplx";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    rev = "v${version}";
    hash = "sha256-Mvlbu69iBoJ2tP+WaQ4jV+nNzCua52FiK7hntFhz9b8=";
  };

  vendorHash = "sha256-vAA9G66IMpxiGX3kC7lCxqgwsL/qM8AbXQ1e6tzN1xM=";
}
