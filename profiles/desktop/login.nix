{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.login;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.desktop.login = {
    enable = lib.mkEnableOption "login";
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${lib.getExe pkgs.tuigreet} --cmd ${config.profiles.desktop.compositorProfile.sessionCmd}";
      };
      useTextGreeter = true;
    };

    security.pam = {
      # greetd cannot be configured by `login` provided by services.gnome.gnome-keyring
      services."greetd".enableGnomeKeyring = true;
    };

    home-manager.users.${user} = {
      programs.bash.profileExtra =
        # Workaround for a bug in timezone handling.
        # Similar to legacy issue https://issues.chromium.org/issues/40540835,
        # instead of reading /etc/localtime, Chromium falls back to ICU etc. for timezone information,
        # which returns `CST` when in `Asia/Shanghai`, which can also be parsed as "Central Standard Time",
        # causing timezone to be set as `America/Chicago` inside chromium sandbox.
        # We set `TZ` manually on login to avoid such behavior for chromium the browser and all electron apps.
        ''
          export TZ=$(${lib.getExe' pkgs.systemd "timedatectl"} show --property=Timezone --value)
        '';
    };
  };
}
