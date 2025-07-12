{
  config,
  helpers,
  lib,
  ...
}:
let
  cfg = config.profiles.services;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.services = {

  };

  config = lib.mkIf cfg.enable {

  };
}
