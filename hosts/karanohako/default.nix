{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    outputs.nixosModules.base
    outputs.nixosModules.base-devel

    inputs.home-manager-stable.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ./nixos
  ];

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

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users."merrkry" = {
      imports = [
        outputs.homeManagerModules.base
        outputs.homeManagerModules.base-devel

        ./home-manager
      ];
    };
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  time.timeZone = "Europe/Berlin";
}
