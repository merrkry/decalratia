{ lib, config, ... }:
let
  cfg = config.profiles.cli;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.cli = {

  };

  config = lib.mkIf cfg.enable {

  };
}
