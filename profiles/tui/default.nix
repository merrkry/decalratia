{ config, lib, ... }:
let
  cfg = config.profiles.tui;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.tui = {

  };

  config = lib.mkIf cfg.enable {

  };
}
