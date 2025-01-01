{ inputs, lib, ... }:
{
  imports = (lib.mkModulesList ./.) ++ [ "${inputs.secrets}/perimadeia/nixos.nix" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

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

  sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";

  time.timeZone = "Europe/Berlin";
}
