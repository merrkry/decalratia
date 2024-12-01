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
    outputs.nixosModules.rootfs-cleanup

    inputs.home-manager-stable.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops

    ./nixos

    "${inputs.secrets}/perimadeia/nixos.nix"
  ];

  nixpkgs.overlays = [
    outputs.overlays.additions
    outputs.overlays.modifications
    outputs.overlays.unstable-packages
  ];

  users.users = {
    "merrkry" = {
      hashedPassword = "$y$j9T$Sgcp0Wdv00yqYcNv2QYeZ0$AsMUpgwygZW1UXDgmIcpi.QrbFVkBpdG25c5xTQckI2";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi"
      ];
      extraGroups = [ "wheel" ];
      linger = true;
    };
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users."merrkry" = {
      imports = [
        ./home-manager
        outputs.homeManagerModules.base
        outputs.homeManagerModules.base-devel
      ];
    };
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
  };

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";

  time.timeZone = "Europe/Berlin";

  system.stateVersion = "24.05";
}
