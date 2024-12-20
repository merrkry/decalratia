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

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # desktop-oriented, unstable branch

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
    { self, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations =
        builtins.mapAttrs
          (
            hostName:
            {
              channel,
              hostPlatform,
              stateVersion,
              mainUser ? "merrkry",
            }:
            let
              channelInput = inputs."nixpkgs-${channel}";
              hmInput = inputs."home-manager-${channel}";
            in
            channelInput.lib.nixosSystem {
              specialArgs =
                let
                  lib = channelInput.lib.extend self.overlays.extraLibs;
                  # calls flake inputs directly, otherwise causes infinite recursion
                  # TODO: add flake registry
                  inputs = self.inputs // {
                    nixpkgs = channelInput;
                  };
                  user = mainUser;
                in
                {
                  inherit
                    inputs
                    lib
                    outputs
                    user
                    ;
                };
              modules = [
                ./hosts/${hostName}
                {
                  networking = { inherit hostName; };
                  nixpkgs = {
                    overlays = [
                      (
                        if channelInput == inputs.nixpkgs-unstable then
                          self.overlays.stablePackages
                        else
                          self.overlays.unstablePackages
                      )
                    ];
                    inherit hostPlatform;
                  };
                  system = { inherit stateVersion; };
                }
                hmInput.nixosModules.home-manager
                ./profiles
              ];
            }
          )
          {
            "akahi" = {
              channel = "unstable";
              hostPlatform = "x86_64-linux";
              stateVersion = "24.05";
            };

            "cryolite" = {
              channel = "unstable";
              hostPlatform = "x86_64-linux";
              stateVersion = "24.11";
            };

            "karanohako" = {
              channel = "stable";
              hostPlatform = "x86_64-linux";
              stateVersion = "24.05";
            };

            "perimadeia" = {
              channel = "stable";
              hostPlatform = "x86_64-linux";
              stateVersion = "24.05";
            };
          };
    };
}
