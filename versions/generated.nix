# This file was generated by nvfetcher, please do not modify it manually.
{ fetchgit, fetchurl, fetchFromGitHub, dockerTools }:
{
  linux-zen = {
    pname = "linux-zen";
    version = "v6.13.1-zen3";
    src = fetchFromGitHub {
      owner = "zen-kernel";
      repo = "zen-kernel";
      rev = "v6.13.1-zen3";
      fetchSubmodules = false;
      sha256 = "sha256-HgZkH16sDfxiWouRMwh54NfQpIQ/GVZsfh6msvHycf0=";
    };
  };
}
