{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.bluetooth;
in
{
  options.profiles.desktop.bluetooth = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {
        General = {
          Experimental = true;
          FastConnectable = true;
        };
      };
    };

    home-manager.users.${user} = {

      home.packages = with pkgs; [ bluetuith ];

    };

  };
}
