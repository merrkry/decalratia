{ lib, pkgs, ... }:
{
  imports = lib.mkModulesList ./.;

  services.userborn.enable = lib.mkForce false;

  boot.kernelPackages = pkgs.linuxPackages_cachyos;
}
