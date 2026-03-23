{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.noctalia;
  hmConfig = config.home-manager.users.${user};

  basePackage = pkgs.noctalia-shell; # inputs.noctalia.packages.${config.nixpkgs.system}.default;

  # Workaround IME bug:
  # https://github.com/noctalia-dev/noctalia-shell/issues/2212
  # Workaround missing icons:
  # https://docs.noctalia.dev/getting-started/faq/#why-are-some-of-my-app-icons-missing
  package = pkgs.symlinkJoin {
    name = "noctalia-shell-extended";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/noctalia-shell \
        --unset QT_IM_MODULE \
        --unset QT_IM_MODULES \
        --set QT_QPA_PLATFORM "wayland;xcb" \
        --set QT_QPA_PLATFORMTHEME "gtk3"
    '';
    inherit (basePackage) meta;
  };

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
    profiles.desktop.swaylock.enable = false;

    home-manager.users.${user} = {
      home.packages = [ package ];

      services.swayidle = {
        enable = true;
        events = {
          # https://github.com/noctalia-dev/noctalia-shell/issues/1066
          before-sleep = "${lib.getExe package} ipc call lockScreen lock";
        };
      };

      systemd.user.tmpfiles.rules = [
        "L+ ${hmConfig.xdg.userDirs.pictures}/Desktop/Wallpapers/default.png - - - - ${wallpaper}"
        "L+ ${hmConfig.xdg.userDirs.pictures}/Desktop/Avatar.png - - - - ${avatar}"
      ];
    };
  };
}
