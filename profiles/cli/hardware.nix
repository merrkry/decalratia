{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.cli.hardware;
in
{
  options.profiles.cli.hardware = {
    enable = lib.mkEnableOption "hardware";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      exfatprogs
      e2fsprogs
      usbutils
      pciutils
      lm_sensors
    ];

  };
}
