{
  inputs,
  outputs,
  user,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
    inputs.niri-flake.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    inputs.chaotic.nixosModules.default
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

    chaotic.nyx.cache.enable = false;
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

    home-manager = {
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs outputs; };
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user} = {
        imports = [ ../modules/home-manager ];
      };
    };

  };
}
