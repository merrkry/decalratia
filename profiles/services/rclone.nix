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
  mkMountService = name: path: mountPoint: {
    Unit = {
      After = lib.mkIf config.networking.networkmanager.enable [ "NetworkManager-wait-online.service" ];
    };
    Service = {
      Type = "notify";
      Environment = [ "PATH=/run/wrappers/bin" ];
      ExecStartPre = "${lib.getExe' pkgs.coreutils "mkdir"} -p ${mountPoint}";
      ExecStart = lib.concatStringsSep " " [
        (lib.getExe' pkgs.rclone "rclone")
        "mount"
        "--config=${config.sops.secrets."rclone/${name}".path}"
        "--vfs-cache-mode full"
        "--vfs-cache-max-age 168h"
        "--use-server-modtime"
        "--write-back-cache"
        "--drive-chunk-size 128M"
        "--allow-non-empty"
        "${name}:${path}"
        "${mountPoint}"
      ];
      Restart = "on-failure";
      RestartSec = 60;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
in
{
  options.profiles.services.rclone = {
    enable = lib.mkEnableOption "rclone";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets =
      let
        owner = user;
        sopsFile = "${inputs.secrets}/secrets.yaml";
      in
      {
        "rclone/dufs" = { inherit owner sopsFile; };
      };

    home-manager.users.${user} = {
      # TODO: consider migrate to home-manager/programs.rclone
      systemd.user.services = {
        "rclone-dufs" = mkMountService "dufs" "/" "%h/Documents/DUFS";
      };
    };
  };
}
