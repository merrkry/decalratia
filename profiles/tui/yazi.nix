{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.yazi;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.tui.yazi = {
    enable = lib.mkEnableOption "yazi";
    enableDesktopUtils = lib.mkEnableOption "yazi" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      # https://yazi-rs.github.io/docs/installation
      home.packages =
        with pkgs;
        (
          [
            _7zz-rar
            jq
            fd
            ripgrep
            fzf
            zoxide
          ]
          ++ (lib.optionals cfg.enableDesktopUtils [
            ffmpeg
            poppler
            imagemagick
            wl-clipboard
          ])
          ++ [
            (ouch.override { enableUnfree = true; })
          ]
        );

      programs.yazi = {
        enable = true;

        package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };

        plugins = with pkgs.yaziPlugins; {
          ouch = ouch;
        };

        keymap = {
          mgr.prepend_keymap = [
            {
              on = [ "C" ];
              run = "plugin ouch tar.zst";
              desc = "Compress with ouch";
            }
          ];
        };

        settings = {
          mgr = {
            ratio = [
              0
              4
              6
            ];
          };

          opener = {
            extract = [
              {
                run = "ouch d -y \"$@\"";
                desc = "Extract here with ouch";
                for = "unix";
              }
            ];
          };

          # https://yazi-rs.github.io/docs/tips/#folder-previewer
          # How to scale this?
          plugin = {
            prepend_preloaders = [
              {
                name = "${hmConfig.home.homeDirectory}/Documents/DUFS/**";
                run = "noop";
              }
              {
                name = "${hmConfig.home.homeDirectory}/Documents/Nextcloud/**";
                run = "noop";
              }
            ];

            prepend_previewers = [
              # Put these before the the mime types below, to ensure preview on remote fs are disabled.
              {
                name = "${hmConfig.home.homeDirectory}/Documents/DUFS/**";
                run = "noop";
              }
              {
                name = "${hmConfig.home.homeDirectory}/Documents/Nextcloud/**";
                run = "noop";
              }

              {
                mime = "application/*zip";
                run = "ouch";
              }
              {
                mime = "application/x-tar";
                run = "ouch";
              }
              {
                mime = "application/x-bzip2";
                run = "ouch";
              }
              {
                mime = "application/x-7z-compressed";
                run = "ouch";
              }
              {
                mime = "application/x-rar";
                run = "ouch";
              }
              {
                mime = "application/vnd.rar";
                run = "ouch";
              }
              {
                mime = "application/x-xz";
                run = "ouch";
              }
              {
                mime = "application/xz";
                run = "ouch";
              }
              {
                mime = "application/x-zstd";
                run = "ouch";
              }
              {
                mime = "application/zstd";
                run = "ouch";
              }
              {
                mime = "application/java-archive";
                run = "ouch";
              }
            ];
          };
        };

        theme = {
          tabs = {
            sep_inner = {
              open = "";
              close = "";
            };
            sep_outer = {
              open = "";
              close = "";
            };
          };
        };
      };

      stylix.targets.yazi.enable = true;
    };
  };
}
