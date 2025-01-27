{
  description = "Yet another NixOS flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # general purpose

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # desktop-oriented, unstable branch

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager-unstable";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # server-oriented, stable branch

    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
      inputs.nixpkgs-24_11.follows = "nixpkgs-stable";
    };

    # secrets

    secrets = {
      url = "github:merrkry/declaratia-secrets";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      lib = inputs.nixpkgs-unstable.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = inputs.nixpkgs-unstable.lib.genAttrs systems;
      machines = {
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

        "hoshinouta" = {
          channel = "stable";
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
        };

        "karanohako" = {
          channel = "stable";
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
        };

        "perimadeia" = {
          channel = "stable";
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
        };

        "sapphire" = {
          channel = "stable";
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
          remoteBuild = false;
        };
      };
    in
    {
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = builtins.mapAttrs (
        hostName:
        {
          channel,
          hostPlatform,
          stateVersion,
          mainUser ? "merrkry",
          ...
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
              inputs = self.inputs // {
                nixpkgs = channelInput;
                home-manager = hmInput;
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
      ) machines;

      devShells = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs-unstable { inherit system; };
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = [
                deploy-rs
                nixd
                nixfmt-rfc-style
                nix-tree
                nh
                nvfetcher
              ];
            };
        }
      );

      deploy =
        # Overlay to use deploy-rs from nixpkgs for deployment
        # Seems too heavy to import nixpkgs twice. Looking for a fix.
        let
          deployPkgs =
            system:
            (import inputs.nixpkgs-unstable {
              inherit system;
              overlays = [
                inputs.deploy-rs.overlays.default
                (final: prev: {
                  deploy-rs =
                    let
                      pkgs = import inputs.nixpkgs-unstable { inherit system; };
                    in
                    {
                      inherit (pkgs) deploy-rs; # use prev instead of pkgs will cause error
                      lib = prev.deploy-rs.lib;
                    };
                })
              ];
            });
        in
        {
          sshUser = "remote-deployer";
          nodes = builtins.mapAttrs (
            hostName:
            {
              hostPlatform,
              remoteBuild ? true,
              ...
            }:
            {
              hostname = hostName;
              profiles.system = {
                user = "root";
                path = (deployPkgs hostPlatform).deploy-rs.lib.activate.nixos self.nixosConfigurations.${hostName};
              };
              inherit remoteBuild;
            }
          ) machines;
        };

      checks = builtins.mapAttrs (
        system: deployLib: deployLib.deployChecks self.deploy
      ) inputs.deploy-rs.lib;

      build = lib.pipe machines [
        (lib.mapAttrsToList (
          hostName: properties: {
            ${properties.hostPlatform}.${hostName} =
              self.nixosConfigurations.${hostName}.config.system.build.toplevel;
          }
        ))
        (lib.foldAttrs (lib.recursiveUpdate) { })
      ];
    };
}
