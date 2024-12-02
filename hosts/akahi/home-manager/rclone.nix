{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  mkRcloneMount =
    { name, path }:
    {
      Unit = {
        Description = "rclone: Remote FUSE filesystem for cloud storage config";
        Documentation = [ "man:rclone(1)" ];
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "notify";
        ExecStartPre = ''
          -${pkgs.coreutils-full}/bin/mkdir -p ${path}
        '';
        # --umask 022
        # --allow-other
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --config=%h/.config/rclone/rclone.conf \
            --vfs-cache-mode full \
            --vfs-cache-max-age 168h \
            --use-server-modtime \
            --write-back-cache \
            --transfers 1024 \
            --checkers 1024 \
            --drive-chunk-size 128M \
            ${name}: ${path}
        '';
        ExecStop = ''
          ${pkgs.fuse}/bin/fusermount -u ${path}
        '';
        Restart = "on-failure";
        RestartSec = 60;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
in
{
  # Rclone config, which is in ~/.config/rclone/rclone.conf,
  # must exist for these to work!
  # As the config is dynamically modified by rclone with new tokens,
  # it is very hard to manage declaratively

  # https://discourse.nixos.org/t/systemd-templates/36356
  systemd.user.services = {
    "rclone-onedrive" = mkRcloneMount {
      name = "onedrive";
      path = "${config.home.homeDirectory}/Documents/onedrive";
    };
    # "rclone-gdrive" = mkRcloneMount {
    #   name = "gdrive";
    #   path = "${config.home.homeDirectory}/Documents/gdrive";
    # };
  };
}
