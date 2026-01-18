{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.niri;
  hmConfig = config.home-manager.users.${user};
  screenshotsPath = "${hmConfig.xdg.userDirs.pictures}/Screenshots";
in
{
  options.profiles.desktop.niri = {
    enable = lib.mkEnableOption "niri" // {
      default = config.profiles.desktop.enable;
    };
    package = lib.mkPackageOption pkgs "niri" { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";

      home = {
        packages = [
          cfg.package
          config.profiles.desktop.xwayland-satellite.package # launched by niri automatically since niri 25.08
        ];
        sessionVariables = {
          NIXOS_OZONE_WL = 1;
          QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        };
      };

      systemd.user.tmpfiles.rules = [
        "d ${screenshotsPath} - - - 14d -"
        "d ${hmConfig.xdg.userDirs.pictures}/Steam - - - 14d -"
      ];
    };
  };
}
