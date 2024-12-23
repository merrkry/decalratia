{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.yazi;
in
{
  options.profiles.cli.yazi = {
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
            p7zip-rar
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
          manager = {
            ratio = [
              0
              4
              6
            ];
          };
        };
      };

    };

  };
}
