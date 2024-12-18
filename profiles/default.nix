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
    inputs.niri-flake.nixosModules.niri
    inputs.stylix.nixosModules.stylix
    inputs.chaotic.nixosModules.default
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

    home-manager.users.${user} = {
      imports = [ ../modules/home-manager ];
    };

  };
}
