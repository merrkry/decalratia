{
  description = "Yet another NixOS flake";

  inputs = {
    nixpkgs.url = "github:merrkry/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    sops = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:zhaofengli/colmena";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        stable.follows = "nixpkgs-stable";
        flake-utils.follows = "flake-utils";
        flake-compat.follows = "flake-compat";
      };
    };

    stylix = {
      url = "github:nix-community/stylix/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        nur.follows = "nur";
      };
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.follows = "rust-overlay";
      };
    };

    flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";

    nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        git-hooks.follows = "git-hooks-nix";
      };
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay/master";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        flake-compat.follows = "flake-compat";
      };
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    determinate = {
      url = "github:DeterminateSystems/nix-src/v3.15.2";
      # Also introduces `nixpkgs-regression` `nixpkgs-23-11` in input for some reason.
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks-nix.follows = "git-hooks-nix";
      };
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt";
      };
    };

    # Personal projects

    secrets = {
      url = "github:merrkry/declaratia-secrets";
      flake = false;
    };

    anipler = {
      url = "github:merrkry/anipler";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
      nixpkgsFor = forAllSystems (
        system:
        (import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.colmena.overlays.default
            inputs.nur.overlays.default

            self.overlays.extraPackages
            self.overlays.modifications
            self.overlays.stablePackages
          ];

          config = {
            allowUnfreePredicate =
              pkg:
              builtins.elem (lib.getName pkg) [
                "7zz"
                "claude-code"
                "code"
                "nvidia-persistenced"
                "nvidia-x11"
                "obsidian"
                "open-webui"
                "ouch"
                "rime-moegirl"
                "steam"
                "steam-unwrapped"
                "chromium"
                "chromium-unwrapped"
                "ungoogled-chromium"
                "ungoogled-chromium-unwrapped"
                "via"
                "vscode"
                "vscode-extension-github-copilot"
                "vscode-with-extensions"
                "widevine-cdm"
              ];
            permittedInsecurePackages = [ "olm-3.2.16" ];
          };
        })
      );
      helpers = import ./helpers { inherit inputs lib; };
      machines = {
        "akahi" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
          tags = [
            "build"
            "desktop"
            "home"
          ];
        };

        "cryolite" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
          tags = [
            "desktop"
            "home"
          ];
        };

        "ilmenite" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "25.05";
          tags = [
            "build"
            "cloud"
          ];
        };

        "karanohako" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.05";
          tags = [ "home" ];
        };

        "sapphire" = {
          hostPlatform = "x86_64-linux";
          stateVersion = "24.11";
          tags = [ "cloud" ];
        };
      };
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgsFor.${system});
      legacyPackages = nixpkgsFor;
      overlays = import ./overlays { inherit helpers inputs; };

      devShells = forAllSystems (system: {
        default =
          with nixpkgsFor.${system};
          mkShell {
            nativeBuildInputs = [
              attic-client
              chezmoi
              colmena
              nixd
              nixfmt
              nix-tree
              nh
              nvfetcher
            ];
          };
      });

      nixosConfigurations = self.outputs.colmenaHive.nodes;

      colmenaHive = inputs.colmena.lib.makeHive (
        {
          meta = {
            nixpkgs = nixpkgsFor."x86_64-linux";
            nodeNixpkgs = builtins.mapAttrs (hostName: hostAttr: nixpkgsFor.${hostAttr.hostPlatform}) machines;
            specialArgs =
              let
                inherit (self) outputs;
                user = "merrkry";
              in
              {
                inherit
                  helpers
                  inputs
                  outputs
                  self
                  user
                  ;
              };
          };

          defaults =
            { ... }:
            {
              imports = [
                inputs.home-manager.nixosModules.home-manager
                ./profiles
              ];
            };
        }
        // (builtins.mapAttrs (hostName: hostAttr: {
          deployment = rec {
            inherit (hostAttr) tags;
            allowLocalDeployment = builtins.elem "build" tags || builtins.elem "desktop" tags;
            buildOnTarget = builtins.elem "build" tags;
            sshOptions = [ "-A" ];
            targetUser = "deployer";
          };

          networking = { inherit hostName; };
          system = { inherit (hostAttr) stateVersion; };

          imports = [
            ./hosts/${hostName}
          ]
          ++ ((p: if builtins.pathExists p then [ p ] else [ ]) "${inputs.secrets}/${hostName}");
        }) machines)
      );

      build = (lib.foldAttrs lib.recursiveUpdate { }) (
        (lib.mapAttrsToList (hostName: properties: {
          ${properties.hostPlatform}.${hostName} =
            self.outputs.nixosConfigurations.${hostName}.config.system.build.toplevel;
        }) machines)
        ++ [
          self.outputs.packages
          self.outputs.devShells
        ]
      );
    };
}
