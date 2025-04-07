{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.base.utils;
in
{
  options.profiles.base.utils = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
  };

  config = lib.mkIf cfg.enable {
    profiles.tui.micro.enable = true;

    environment = {
      sessionVariables = {
        EDITOR = lib.mkDefault "micro";
      };

      systemPackages = with pkgs; [
        wget
        curl
        vim
        git
        rsync
      ];
    };
  };
}
