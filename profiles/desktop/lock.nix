{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.lock;
in
{
  options.profiles.desktop.lock = {
    enable = lib.mkEnableOption "lock";
    lockCmd = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs = {
        swaylock.enable = lib.mkDefault (cfg.lockCmd == "");
      };

      services.swayidle = {
        enable = true;
        extraArgs = lib.mkForce [ ]; # remove `-w` to avoid double lock bug
        events = {
          lock = if cfg.lockCmd != "" then cfg.lockCmd else "${lib.getExe pkgs.swaylock} --daemonize";
          before-sleep = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
        };
        timeouts = [
          {
            timeout = 300;
            command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
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

      stylix.targets.swaylock.enable = true;
    };
  };
}
