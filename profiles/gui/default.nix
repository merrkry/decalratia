{
  config,
  helpers,
  lib,
  ...
}:
let
  cfg = config.profiles.gui;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.gui = {

  };

  config = lib.mkIf cfg.enable {

  };
}
