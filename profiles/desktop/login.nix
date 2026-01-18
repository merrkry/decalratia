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
  };
}
