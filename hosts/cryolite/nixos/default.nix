{ lib, pkgs, ... }:
{
  imports = lib.mkModulesList ./.;
}
