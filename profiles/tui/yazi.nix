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
    enable = lib.mkEnableOption' { };
    enableDesktopUtils = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
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
        );

      programs.yazi = {
        enable = true;
        settings = {
          mgr = {
            ratio = [
              0
              4
              6
            ];
          };
          # https://yazi-rs.github.io/docs/tips/#folder-previewer
          # How to scale this?
          plugin.prepend_preloaders = [
            {
              name = "${hmConfig.home.homeDirectory}/Documents/DUFS/**";
              run = "noop";
            }
            {
              name = "${hmConfig.home.homeDirectory}/Documents/Nextcloud/**";
              run = "noop";
            }
          ];
          plugin.prepend_previewers = [
            {
              name = "${hmConfig.home.homeDirectory}/Documents/DUFS/**";
              run = "noop";
            }
            {
              name = "${hmConfig.home.homeDirectory}/Documents/Nextcloud/**";
              run = "noop";
            }
          ];
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
