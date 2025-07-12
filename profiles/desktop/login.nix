{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.login;
in
{
  options.profiles.desktop.login = {
    enable = lib.mkEnableOption "login" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${lib.getExe pkgs.greetd.tuigreet} --cmd niri-session";
      };
    };

    security.pam = {
      # greetd cannot be configured by `login` provided by services.gnome.gnome-keyring
      services."greetd".enableGnomeKeyring = true;
    };

    home-manager.users.${user} = {
      programs = {
        swaylock.enable = true;
      };

      services = {
        swayidle = {
          enable = true;
          extraArgs = lib.mkForce [ ]; # remove `-w` to avoid double lock bug
          events = [
            {
              event = "lock";
              command = "${lib.getExe pkgs.swaylock} --daemonize";
            }
            {
              event = "before-sleep";
              command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
            }
          ];
          timeouts = [
            {
              timeout = 300;
              command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session";
            }
            {
              timeout = 600;
              command = "${lib.getExe' pkgs.niri "niri"} msg action power-off-monitors";
            }
            {
              timeout = 1800;
              command = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
            }
          ];
        };
      };

      stylix.targets.swaylock.enable = true;
    };
  };
}
