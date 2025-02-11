{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "deeplx";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    rev = "v${version}";
    hash = "sha256-D6U00rCjMmzp2nT7IbYKtDluJdM75JloIJADy+Wg2/0=";
  };

  vendorHash = "sha256-vAA9G66IMpxiGX3kC7lCxqgwsL/qM8AbXQ1e6tzN1xM=";
}
