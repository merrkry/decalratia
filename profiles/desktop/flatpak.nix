{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.flatpak;
  hmConfig = config.home-manager.users.${user};
  untrustedFilesystemsOverride = [
    "xdg-public-share"
    "!xdg-desktop"
    "!xdg-documents"
    "!xdg-download"
    "!xdg-music"
    "!xdg-pictures"
    "!xdg-templates"
    "!xdg-videos"
  ];
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
                # "xdg-data/fonts:ro"
                # "xdg-data/icons:ro"
                "/run/current-system/sw/share/X11/fonts:ro;"
              ];

              unset-environment = [
                "VK_DRIVER_FILES"
                "__EGL_VENDOR_LIBRARY_FILENAMES"
              ];
            };
          };

          "com.baidu.NetDisk" = {
            Context = {
              filesystems = untrustedFilesystemsOverride;
            };
          };

          "com.qq.QQ" = {
            Context = {
              filesystems = untrustedFilesystemsOverride;
              sockets = [ "!wayland" ];
            };
            Environment = {
              GTK_IM_MODULE = "fcitx";
            };
          };

          "com.tencent.WeChat" = {
            Context = {
              filesystems = untrustedFilesystemsOverride;
              unset-environment = [ "QT_AUTO_SCREEN_SCALE_FACTOR" ];
            };
            Environment = {
              "QT_SCALE_FACTOR=" = "1.0";
            };
          };

          "com.valvesoftware.Steam" = {
            Environment = {
              PATH = "/app/bin:/app/utils/bin:/usr/bin:/usr/lib/extensions/vulkan/gamescope/bin";
            };
          };
        };

        packages = [ "com.github.tchx84.Flatseal" ];

        uninstallUnmanaged = true;
        uninstallUnused = true;

        update = {
          onActivation = false;
          auto = {
            enable = true;
            onCalendar = "weekly";
          };
        };
      };

      # themes mounted under ~/.themes will cause steam unable to launch
      # see https://github.com/danth/stylix/issues/1093
      stylix.targets.gtk.flatpakSupport.enable = false;

      systemd.user.tmpfiles.rules = [
        "L+ ${hmConfig.xdg.dataHome}/fonts/system - - - - /run/current-system/sw/share/X11/fonts"
      ];
    };
  };
}
