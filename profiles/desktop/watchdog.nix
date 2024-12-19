{ config, lib, ... }:
let
  cfg = config.profiles.desktop.watchdog;
in
{
  options.profiles.desktop.watchdog = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      extraModprobeConfig = ''
        blacklist iTCO_wdt
        blacklist sp5100_tco
      '';
      kernelParams = [ "nowatchdog" ];
    };

  };
}
