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

        documentation.nixos.enable = false;
        # will be enabled by fish, making rebuild extremely slow
        documentation.man.generateCaches = lib.mkForce false;

        nix =
          let
            flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
            unstable = if builtins.hasAttr "unstable" pkgs then pkgs.unstable else pkgs;
          in
          {
            package = unstable.nixVersions.latest;
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
                "remote-deployer"
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

        nixpkgs = {
          config.allowUnfree = true;
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
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHylx0U1U4NlR9RIadf1vGlKf/C+dJN9GC9oGhwQlMZd merrkry@hoshinouta"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAg9BDaX6NeZmA3ux+Zr5Dd6zhBCu4Ohs0iORgojXN4 merrkry@karanohako"
          ];
        };

        users.groups.remotebuild = { };
      }
      (lib.optionalAttrs (lib.versionAtLeast lib.version "25.05pre") { system.rebuild.enableNg = true; })
    ]
  );
}
