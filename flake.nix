{
  description = "Yet another NixOS flake";

  inputs = {
    nixpkgs.url = "github:merrkry/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lix = {
      # 2.92 regression https://github.com/NixOS/nixpkgs/pull/375030
      url = "https://git.lix.systems/lix-project/nixos-module/archive/release-2.91.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        utils.follows = "flake-utils";
      };
    };

    stylix = {
      url = "github:danth/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        nur.follows = "nur";
      };
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
      };
    };

    xremap = {
      url = "github:xremap/nix-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.6.0";

    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-24_11.follows = "nixpkgs-stable";
        flake-compat.follows = "flake-compat";
      };
    };

    secrets = {
      url = "github:merrkry/declaratia-secrets";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;
      lib = inputs.nixpkgs.lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
      machines = {
        "akahi" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
        };

        "cryolite" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
        };

        "hoshinouta" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
        };

        "karanohako" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
        };

        "perimadeia" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
        };

        "sapphire" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
          remoteBuild = false;
        };
      };
    in
    {
      packages = forAllSystems (system: import ./pkgs inputs.nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = builtins.mapAttrs (
        hostName:
        {
          hostPlatform,
          stateVersion,
          mainUser ? "merrkry",
          ...
        }:
        inputs.nixpkgs.lib.nixosSystem {
          specialArgs =
            let
              lib = inputs.nixpkgs.lib.extend self.overlays.extraLibs;
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
                overlays = [ self.overlays.stablePackages ];
                inherit hostPlatform;
              };
              system = { inherit stateVersion; };
            }
            inputs.home-manager.nixosModules.home-manager
            ./profiles
          ];
        }
      ) machines;

      devShells = forAllSystems (
        system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        {
          default =
            with pkgs;
            mkShell {
              nativeBuildInputs = [
                chezmoi
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
            (import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.deploy-rs.overlays.default
                (final: prev: {
                  deploy-rs =
                    let
                      pkgs = import inputs.nixpkgs { inherit system; };
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
