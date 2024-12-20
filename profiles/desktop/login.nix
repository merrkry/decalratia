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
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    services.greetd = {
      enable = true;
      settings = {
        default_session.command = "${lib.getExe pkgs.greetd.tuigreet} --cmd niri-session";
      };
    };

    security.pam = {
      services."greetd".enableGnomeKeyring = true;
    };

    home-manager.users.${user} = {

      programs.swaylock.enable = true;

    };

  };
}
