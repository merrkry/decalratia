# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  linux-zen = {
    pname = "linux-zen";
    version = "v6.13.2-zen1";
    src = fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v6.13.2-zen1";
      fetchSubmodules = false;
      sha256 = "sha256-JAVu75QATw+hhMiG732KUwuTY41HS2F4L9tylhVwdFA=";
    };
  };
}
