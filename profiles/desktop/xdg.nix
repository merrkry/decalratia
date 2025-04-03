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
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      configPackages = [ pkgs.niri ];
      extraPortals = with pkgs; [
        gnome-keyring
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.common = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.portal.Secret" = [ "gnome-keyring" ];
      };
    };

    home-manager.users.${user} = {
      xdg = {
        userDirs = {
          enable = true;
          createDirectories = true;
        };
      };
    };
  };
}
