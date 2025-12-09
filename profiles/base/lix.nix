{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.base.lix;
  lixBranch = "latest";
in
{
  options.profiles.base.lix = {
    enable = lib.mkEnableOption "lix" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # https://lix.systems/add-to-config/

    nix.package = pkgs.lixPackageSets.${lixBranch}.lix;

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
  };
}
