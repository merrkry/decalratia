{ config, lib, ... }:
let
  cfg = config.profiles.gui;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.gui = {

  };

  config = lib.mkIf cfg.enable {

  };
}
