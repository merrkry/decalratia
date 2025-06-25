{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.profiles.base.nixd;
in
{
  options.profiles.base.nixd = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
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
            settings = {
              # download-buffer-size = 268435456; # not available in lix
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
                "remote-deployer"
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
              flake-registry = "";
              nix-path = config.nix.nixPath;
              # FIXME: curl often reports `curl: Couldn't find host cache.tsubasa.moe in the /run/secrets/attic-netrc; file; using defaults`
              # and then Nix fails to fetch nix-cache-info. Set substituter to public for now.
              netrc-file = config.sops.secrets."attic-netrc".path;
              narinfo-cache-negative-ttl = 0;
            };
            channel.enable = false;
            registry = (lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs) // {
              p.flake = inputs.nixpkgs;
              pkgs.flake = inputs.nixpkgs;
            };
            nixPath = (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs) ++ [
              "p=flake:nixpkgs"
              "pkgs=flake:nixpkgs"
            ];
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
          };

        nixpkgs.config = {
          allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "7zz"
              "code"
              "nvidia-persistenced"
              "nvidia-x11"
              "obsidian"
              "open-webui"
              "rime-moegirl"
              "steam"
              "steam-unwrapped"
              "chromium"
              "chromium-unwrapped"
              "ungoogled-chromium"
              "ungoogled-chromium-unwrapped"
              "vscode"
              "widevine-cdm"
            ];
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

        # keep flakes inputs not garbage collected
        # https://github.com/oxalica/nixos-config/blob/706adc07354eb4a1a50408739c0f24a709c9fe20/nixos/modules/nix-keep-flake-inputs.nix#L3-L7
        system.extraDependencies =
          let
            collectFlakeInputs =
              input:
              [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
          in
          builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);

        systemd.services.nix-gc.serviceConfig = {
          Nice = 19;
          IOSchedulingClass = "idle";
          MemorySwapMax = 0;
        };

        users.groups."remote-deployer" = { };

        users.users."remote-deployer" = {
          isNormalUser = true;
          createHome = false;
          group = "remote-deployer";
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = lib.sshKeys.trusted;
        };

        users.groups.remotebuild = { };
      }
      (lib.optionalAttrs (lib.versionAtLeast lib.version "25.05pre") { system.rebuild.enableNg = true; })
    ]
  );
}
