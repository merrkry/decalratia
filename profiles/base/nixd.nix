{
  inputs,
  config,
  lib,
  pkgs,
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
            package = pkgs.nixVersions.latest;
            settings = {
              download-buffer-size = 268435456;
              experimental-features = [
                "nix-command"
                "flakes"
                "ca-derivations"
                "auto-allocate-uids"
                "cgroups"
              ];
              auto-allocate-uids = true;
              use-cgroups = true;
              auto-optimise-store = true;
              use-xdg-base-directories = true;
              trusted-users = [
                "root"
                # dangerous, see https://github.com/NixOS/nix/issues/9649#issuecomment-1868001568
                # "@wheel"
              ];
              substituters = [
                "https://nix-community.cachix.org"
                "https://cache.garnix.io"
              ];
              trusted-public-keys = [
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
              ];
              flake-registry = "";
              nix-path = config.nix.nixPath;
            };
            channel.enable = false;
            registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
            nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
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

        nixpkgs = {
          config.allowUnfree = true;
        };

        documentation.nixos.enable = false;
        # will be enabled by fish, making rebuild extremely slow
        documentation.man.generateCaches = lib.mkForce false;

      }
      (lib.optionalAttrs (lib.versionAtLeast lib.version "25.05pre") { system.rebuild.enableNg = true; })
    ]
  );
}
