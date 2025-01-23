{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.rclone;
in
{
  options.profiles.desktop.rclone = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    sops.secrets = {
      "rclone/nextcloud" = {
        owner = user;
        sopsFile = "${inputs.secrets}/secrets.yaml";
      };
    };

    home-manager.users.${user} = {

      systemd.user.services = {
        "rclone-nextcloud" =
          let
            path = "%h/Documents/Nextcloud";
            name = "nextcloud";
          in
          {
            Unit = {
              After = [
                "network-online.target"
                "NetworkManager-wait-online.service"
              ];
              Wants = [ "network-online.target" ];
            };
            Service = {
              Type = "notify";
              ExecStartPre = ''
                -${pkgs.coreutils-full}/bin/mkdir -p ${path}
              '';
              ExecStart = ''
                ${lib.getExe' pkgs.rclone "rclone"} mount \
                  --config=${config.sops.secrets."rclone/nextcloud".path} \
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
      };

    };

  };
}
