{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop.bluetooth;
in
{
  options.profiles.desktop.bluetooth = {
    enable = lib.mkEnableOption "bluetooth";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bluetuith
      bluez
    ];

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
  };
}
