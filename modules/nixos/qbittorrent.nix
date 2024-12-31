{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {

    enable = lib.mkEnableOption "qbittorrent" // {
      default = false;
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/qbittorrent";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "qbittorrent";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.qbittorrent-nox;
    };

    webuiPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
    };

    torrentingPort = lib.mkOption {
      type = lib.types.port;
      default = 6881;
      description = ''
        Open firewall for this port.
        This may also needs to be explicitly set in qbittorrent webui.
      '';
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ cfg.package ];

    users.users."${cfg.user}" = {
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "qBittorrent daemon user";
      homeMode = "0750";
      isSystemUser = true;
    };
    users.groups."${cfg.group}" = { };

    systemd.services.qbittorrent = {

      description = "qBittorrent Daemon";

      wants = [ "network-online.target" ];
      after = [
        "local-fs.target"
        "network-online.target"
        "nss-lookup.target"
      ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${lib.getExe cfg.package} \
            --confirm-legal-notice \
            --profile=${toString cfg.dataDir} \
            --webui-port=${toString cfg.webuiPort} \
            --torrenting-port=${toString cfg.torrentingPort}
        '';
        TimeoutStopSec = 1800; # copied from Archlinux package
        User = cfg.user;
        Group = cfg.group;
      };

    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.torrentingPort ];
      allowedUDPPorts = [ cfg.torrentingPort ];
    };

  };
}
