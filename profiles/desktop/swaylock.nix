{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.swaylock;
  lockCmd = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
in
{
  options.profiles.desktop.swaylock = {
    enable = lib.mkEnableOption "swaylock";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs = {
        swaylock.enable = true;
      };

      services.swayidle = {
        enable = true;
        events = {
          lock = "${lib.getExe pkgs.swaylock} --daemonize";
          before-sleep = cfg.lockCmd;
        };
        timeouts = [
          {
            timeout = 300;
            command = lockCmd;
          }
          {
            timeout = 600;
            command = config.profiles.desktop.compositorProfile.screenOffCmd;
          }
        ]
        ++ (lib.optional config.profiles.desktop.tweaks.powersave {
          timeout = 1800;
          command = "${lib.getExe' pkgs.systemd "systemctl"} sleep";
        });
      };
    };
  };
}
