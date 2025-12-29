{
  config,
  helpers,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:
let
  cfg = config.profiles.base.nixd;
in
{
  options.profiles.base.nixd = {
    enable = lib.mkEnableOption "nixd" // {
      default = config.profiles.base.enable;
    };
    nixFlavor = lib.mkOption {
      type = lib.types.enum [
        "cppnix"
        "lix"
        "determinate"
      ];
      default = "determinate";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        nix =
          let
            flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
          in
          {
            # nix.conf is required during build time, add ! to let it fail silently
            extraOptions = ''
              !include ${config.sops.secrets."nix".path}
            '';

            settings = lib.mkMerge [
              {
                experimental-features = [
                  "nix-command"
                  "flakes"
                  "auto-allocate-uids"
                  "cgroups"
                ];
                auto-allocate-uids = true;
                use-cgroups = true;
                auto-optimise-store = true;
                use-xdg-base-directories = true;
                trusted-users = [
                  # dangerous, see https://github.com/NixOS/nix/issues/9649#issuecomment-1868001568
                  # "@wheel"
                  "deployer"
                ];
                substituters = [
                  # cache.nixos.org priority: 40
                  "https://cache.tsubasa.moe/selfhosted/" # priority 30
                  # "https://nix-community.cachix.org/" # priority: 41
                  "https://cache.garnix.io/" # priority: 50
                ];
                trusted-public-keys = [
                  "selfhosted:cwEa3KuTCeG4BFjq7q3XgSIbt9F6m1gCywCmAP+VuR8="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
                ];
                # Global registry
                flake-registry = "";
                nix-path = config.nix.nixPath;
                # FIXME: curl often reports `curl: Couldn't find host cache.tsubasa.moe in the /run/secrets/attic-netrc; file; using defaults`
                # and then Nix fails to fetch nix-cache-info. Set substituter to public for now.
                netrc-file = config.sops.secrets."attic-netrc".path;
                narinfo-cache-negative-ttl = 0;
                warn-dirty = false;
              }
              (lib.mkIf (cfg.nixFlavor != "lix") { download-buffer-size = 268435456; })
            ];

            channel.enable = false;
            # System registry
            registry = (lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs) // {
              p.flake = self;
              pkgs.flake = self;
            };
            nixPath = (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs) ++ [
              "p=flake:self"
              "pkgs=flake:self"
            ];
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
          };

        services = {
          angrr = {
            enable = true;
            timer.enable = true;
            enableNixGcIntegration = true;
            # `angrr example-config`
            settings = {
              temporary-root-policies = {
                direnv = {
                  path-regex = "/\\.direnv/";
                  period = "14d";
                };
                result = {
                  path-regex = "/result[^/]*$";
                  period = "7d";
                };
              };
              profile-policies = {
                system = {
                  profile-paths = [ "/nix/var/nix/profiles/system" ];
                  keep-since = "14d";
                  keep-latest-n = 8;
                  keep-booted-system = true;
                  keep-current-system = true;
                };
                user = {
                  profile-paths = [
                    "~/.local/state/nix/profiles/profile"
                    "/nix/var/nix/profiles/per-user/root/profile"
                  ];
                  keep-since = "0d";
                  keep-latest-n = 3;
                };
              };
            };
          };
        };

        sops.secrets =
          let
            sopsArgs = {
              restartUnits = [ "nix-daemon.service" ];
              sopsFile = "${inputs.secrets}/secrets.yaml";
            };
          in
          {
            "attic-netrc" = sopsArgs;
            "nix" = sopsArgs;
          };

        # FIXME: infinite recursion when determinate is in flake inputs
        # keep flakes inputs not garbage collected
        # https://github.com/oxalica/nixos-config/blob/706adc07354eb4a1a50408739c0f24a709c9fe20/nixos/modules/nix-keep-flake-inputs.nix#L3-L7
        # system.extraDependencies =
        #   let
        #     collectFlakeInputs =
        #       input:
        #       [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
        #   in
        #   builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);

        systemd.services.nix-gc.serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          MemorySwapMax = 0;
        };

        users.groups."deployer" = { };

        users.users."deployer" = {
          isSystemUser = true;
          home = "/var/lib/deployer";
          createHome = true;
          group = "deployer";
          extraGroups = [ "wheel" ];
          shell = pkgs.bashInteractive;
          openssh.authorizedKeys.keys = helpers.sshKeys.trusted;
        };

        users.groups.remotebuild = { };
      }

      (lib.mkIf (cfg.nixFlavor == "cppnix") {
        nix.package = pkgs.nixVersions.latest;
      })

      # https://lix.systems/add-to-config/
      (lib.mkIf (cfg.nixFlavor == "lix") (
        let
          lixBranch = "latest";
        in
        {
          nix = {
            package = pkgs.lixPackageSets.${lixBranch}.lix;
          };

          # FIXME: might be some infinite recursion
          nixpkgs.overlays = [
            (final: prev: {
              inherit (final.lixPackageSets.${lixBranch})
                nixpkgs-review
                nix-eval-jobs
                nix-fast-build
                colmena
                ;
            })
          ];
        }
      ))

      (lib.mkIf (cfg.nixFlavor == "determinate") {
        nix = {
          package = inputs.determinate.packages.${config.nixpkgs.system}.default;
          settings = {
            lazy-trees = true;
          };
        };
      })
    ]
  );
}
