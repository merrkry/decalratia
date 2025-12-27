{
  config,
  helpers,
  inputs,
  lib,
  outputs,
  user,
  ...
}:
{
  imports = [
    inputs.sops.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.stylix.nixosModules.stylix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixos-mailserver.nixosModules.mailserver

    ../modules/nixos

    ./base
    ./base-devel
    ./cli
    ./desktop
    ./gui
    ./tui
    ./services

    ./meta.nix
    ./stylix.nix
  ];

  config = {
    users = {
      # https://github.com/NixOS/nixpkgs/pull/199705
      groups = {
        ${user} = {
          gid = 1000;
        };
      };
      users = {
        ${user} = {
          openssh.authorizedKeys.keys = helpers.sshKeys.trusted;
          isNormalUser = true;
          extraGroups = [ "wheel" ];
          group = user;
          uid = 1000;
        };
      };
    };

    services.fwupd.enable = lib.mkDefault (
      config.hardware.cpu.intel.updateMicrocode || config.hardware.cpu.amd.updateMicrocode
    );

    # useless and fails on some network conditions
    systemd.services."fwupd-refresh".enable = false;
    systemd.timers."fwupd-refresh".enable = false;

    home-manager = {
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs outputs; };
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user} = {
        imports = [
          ../modules/home-manager

          inputs.flatpak.homeManagerModules.nix-flatpak

          {
            home = {
              username = user;
              homeDirectory = config.users.users.${user}.home;

              enableNixpkgsReleaseCheck = false;
            };
          }
        ];
      };
    };
  };
}
