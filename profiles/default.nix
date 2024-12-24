{
  config,
  inputs,
  lib,
  outputs,
  user,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.niri-flake.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixos-mailserver.nixosModules.mailserver

    ../modules/nixos

    ./base
    ./base-devel
    ./cli
    ./desktop
    ./gui
  ];

  config = {

    niri-flake.cache.enable = false;

    nixpkgs.overlays = [
      inputs.nur.overlays.default
      outputs.overlays.extraPackages
      outputs.overlays.modifications
    ];

    users.users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
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
          {
            home = {
              username = user;
              homeDirectory = config.users.users.${user}.home;
            };
          }
        ];
      };
    };

  };
}
