{ config, lib, ... }:
let
  cfg = config.profiles.services;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.services = {

  };

  config = lib.mkIf cfg.enable {

  };
}
