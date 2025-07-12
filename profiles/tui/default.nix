{
  config,
  helpers,
  lib,
  ...
}:
let
  cfg = config.profiles.tui;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.tui = {

  };

  config = lib.mkIf cfg.enable {

  };
}
