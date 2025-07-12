{
  config,
  helpers,
  lib,
  ...
}:
let
  cfg = config.profiles.cli;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.cli = {

  };

  config = lib.mkIf cfg.enable {

  };
}
