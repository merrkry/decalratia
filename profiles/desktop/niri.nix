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
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    useUpstreamPackage = lib.mkEnableOption { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";

      home = {
        packages = with pkgs; [
          brightnessctl
          cliphist
          niri
          xwayland-run
        ];
        sessionVariables = {
          QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        };
      };

      systemd.user = {
        tmpfiles.rules = [
          "d ${screenshotsPath} - - - 14d -"
          "d ${hmConfig.xdg.userDirs.pictures}/Steam - - - 14d -"
        ];
      };
    };
  };
}
