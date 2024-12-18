{ lib, ... }:
rec {
  mkEnableOption' =
    {
      default ? false,
    }:
    lib.mkOption {
      inherit default;
      type = lib.types.bool;
      visible = false; # do not generate docs, useless for now
    };
}
