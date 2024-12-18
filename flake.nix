{
  description = "Yet another NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    # general purpose

    impermanence.url = "github:nix-community/impermanence";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # client-oriented, unstable branch

    niri-flake.url = "github:sodiboo/niri-flake";
    niri-flake.inputs.nixpkgs.follows = "nixpkgs-unstable";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    stylix.inputs.home-manager.follows = "home-manager-unstable";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs-unstable";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.nixpkgs.follows = "nixpkgs-unstable";
    chaotic.inputs.home-manager.follows = "home-manager-unstable";

    # server-oriented, stable branch

    nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs-stable";

    # secrets

    secrets.url = "github:merrkry/declaratia-secrets";
    secrets.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      home-manager-unstable,
      nixpkgs-stable,
      home-manager-stable,
      impermanence,
      nixos-hardware,
      sops-nix,
      niri-flake,
      stylix,
      nur,
      chaotic,
      nixos-mailserver,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {

        "akahi" = nixpkgs-unstable.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/akahi ];
        };

        "karanohako" = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/karanohako ];
        };

        "perimadeia" = nixpkgs-stable.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ ./hosts/perimadeia ];
        };

      };
    };
}
