{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.flatpak;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.desktop.flatpak = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    home-manager.users.${user} = {
      home.shellAliases = {
        "flatpak" = "flatpak --user";
      };

      services.flatpak = {
        overrides = {
          global = {
            Context = {
              filesystems = [
                "/nix/store:ro"

                "xdg-config/fontconfig:ro;"
                "xdg-data/fonts:ro"
                "xdg-data/icons:ro"
                "/run/current-system/sw/share/X11/fonts:ro;"
                "${hmConfig.home.homeDirectory}/.themes/adw-gtk3:ro"

                hmConfig.xdg.userDirs.publicShare

                "!xdg-desktop"
                "!xdg-documents"
                "!xdg-download"
                "!xdg-music"
                "!xdg-pictures"
                "!xdg-templates"
                "!xdg-videos"
              ];

              unset-environment = [
                "VK_DRIVER_FILES"
                "__EGL_VENDOR_LIBRARY_FILENAMES"
              ];
            };

            Environment = {
              GTK_THEME = "adw-gtk3";
            };
          };

          "com.qq.QQ" = {
            Environment = {
              GTK_IM_MODULE = "fcitx";
            };
          };

          "com.tencent.WeChat" = {
            Context.unset-environment = [ "QT_AUTO_SCREEN_SCALE_FACTOR" ];
            Environment = {
              "QT_SCALE_FACTOR=" = "1.0";
            };
          };
        };

        packages = [ "com.github.tchx84.Flatseal" ];

        uninstallUnmanaged = false;
        uninstallUnused = true;

        update = {
          onActivation = false;
          auto = {
            enable = true;
            onCalendar = "weekly";
          };
        };
      };
    };
  };
}
