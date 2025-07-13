{ buildGoModule, fetchFromGitHub }:
buildGoModule rec {
  pname = "deeplx";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "OwO-Network";
    repo = "DeepLX";
    tag = "v${version}";
    hash = "sha256-MutYqV4K9UNfoLBw7zRQvzIy1mBnPuLE9tP6NzzXVZg=";
  };

  vendorHash = "sha256-KDprS2vcEzgL7wtfJ75mzhTQEFhYuLcLlHFCcNobNvw=";
}
