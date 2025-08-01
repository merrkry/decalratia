{ config, lib, ... }:
let
  cfg = config.profiles.desktop.plymouth;
in
{
  options.profiles.desktop.plymouth = {
    enable = lib.mkEnableOption "plymouth" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      plymouth.enable = true;

      # Enable "Silent Boot"
      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];

      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      loader.timeout = 0;
    };

    stylix.targets.plymouth.enable = false;

  };
}
