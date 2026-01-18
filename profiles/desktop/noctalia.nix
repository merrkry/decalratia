{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.noctalia;
  hmConfig = config.home-manager.users.${user};

  package = inputs.noctalia.packages.${config.nixpkgs.system}.default;

  avatar = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/merrkry/desktop-resources/refs/heads/master/avatar-red.png";
    sha256 = "sha256-qkPIIzyysJ4e23YYH1qqxlwa5dIa4Gihdt52h/KdEDI=";
  };
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/merrkry/desktop-resources/refs/heads/master/Ajin.png";
    sha256 = "sha256-ClN4I3KAykEkw2BJrjPIxfE66xXLBwshr8kELytIoqM=";
  };
in
{
  options.profiles.desktop.noctalia = {
    enable = lib.mkEnableOption "noctalia" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    profiles.desktop.lock.lockCmd = "${lib.getExe package} ipc call lockScreen lock";

    home-manager.users.${user} = {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      programs.noctalia-shell = {
        inherit package;
        enable = true;
        systemd.enable = true;
      };

      systemd.user = {
        services.noctalia-shell.Service.Environment = lib.mapAttrsToList (key: value: "${key}=${value}") {
          QT_QPA_PLATFORM = "wayland;xcb";
          QT_QPA_PLATFORMTHEME = "gtk3";
          QT_AUTO_SCREEN_SCALE_FACTOR = "1";
        };

        tmpfiles.rules = [
          "L+ ${hmConfig.xdg.userDirs.pictures}/Desktop/Wallpapers/default.png - - - - ${wallpaper}"
          "L+ ${hmConfig.xdg.userDirs.pictures}/Desktop/Avatar.png - - - - ${avatar}"
        ];
      };
    };
  };
}
