{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.xdg;
in
{
  options.profiles.desktop.xdg = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      xdg = {
        portal = {
          enable = true;
          xdgOpenUsePortal = true;
          configPackages = [ config.programs.niri.package ];
          extraPortals = with pkgs; [
            gnome-keyring
            xdg-desktop-portal-gnome
            xdg-desktop-portal-gtk
          ];
          config.common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.portal.Secret" = [ "gnome-keyring" ];
          };
        };

        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };

    };

  };
}
