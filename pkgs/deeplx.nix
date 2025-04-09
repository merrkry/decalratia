{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "deeplx";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${version}";
    hash = "sha256-r8kQzYc4kn5HDJtx7a7xrXUJXuFcxDzCcChtLnVqXmg=";
  };

  vendorHash = "sha256-vAA9G66IMpxiGX3kC7lCxqgwsL/qM8AbXQ1e6tzN1xM=";
}
