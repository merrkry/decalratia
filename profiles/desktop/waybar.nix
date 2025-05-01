{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.waybar;
in
{
  options.profiles.desktop.waybar = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    backlightDevice = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "The backlight device to control";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
      };

      services.network-manager-applet.enable = true;

      systemd.user.services.waybar.Unit.After = [ "graphical-session.target" ];
    };
  };
}
