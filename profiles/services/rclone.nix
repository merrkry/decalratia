{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.services.rclone;
in
{
  options.profiles.services.rclone = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "rclone/nextcloud" = {
        owner = user;
        sopsFile = "${inputs.secrets}/secrets.yaml";
      };
    };

    home-manager.users.${user} = {
      # TODO: consider migrate to home-manager/programs.rclone
      systemd.user.services = {
        "rclone-nextcloud" =
          let
            path = "%h/Documents/Nextcloud";
            name = "nextcloud";
          in
          {
            Unit = {
              After = lib.mkIf config.networking.networkmanager.enable [ "NetworkManager-wait-online.service" ];
            };
            Service = {
              Type = "notify";
              Environment = [ "PATH=/run/wrappers/bin" ];
              ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${path}";
              ExecStart = lib.concatStringsSep " " [
                (lib.getExe' pkgs.rclone "rclone")
                "mount"
                "--config=${config.sops.secrets."rclone/nextcloud".path}"
                "--vfs-cache-mode full"
                "--vfs-cache-max-age 168h"
                "--use-server-modtime"
                "--write-back-cache"
                "--drive-chunk-size 128M"
                "--allow-non-empty"
                "${name}:"
                "${path}"
              ];
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
