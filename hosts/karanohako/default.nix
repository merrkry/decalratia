{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [ ./nixos ];

  profiles = {
    base.enable = true;
    base-devel.enable = true;
  };

  users.users = {
    "merrkry" = {
      extraGroups = [ "wheel" ];
      hashedPassword = "$2b$05$V7CpckgiacL3nM/FZ5Fa0OIAZlw469dZswx32kg7lWXRTL8Zme4fa";
      isNormalUser = true;
      linger = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi"
      ];
    };
  };

  home-manager.users."merrkry" = {
    imports = [ ./home-manager ];
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  time.timeZone = "Europe/Berlin";
}
