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
  mkNoPreviewPreloader = builtins.map (dir: {
    name = dir;
    run = "noop";
  });
  mkNoPreviewPreviewer = mkNoPreviewPreloader;
  mountedDirectories = [

    "${hmConfig.home.homeDirectory}/Documents/DUFS/**"
    "${hmConfig.home.homeDirectory}/Documents/Nextcloud/**"
  ];
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
      programs.yazi = {
        enable = true;

        package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };

        settings = {
          mgr = {
            ratio = [
              0
              4
              6
            ];
          };

          # https://yazi-rs.github.io/docs/tips/#folder-previewer
          plugin = {
            prepend_preloaders = (mkNoPreviewPreloader mountedDirectories);
            prepend_previewers = (mkNoPreviewPreviewer mountedDirectories);
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
