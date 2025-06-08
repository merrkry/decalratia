{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;
  cfg = config.services.dufs;
in
{
  options.services.dufs = {
    enable = lib.mkEnableOption "DUFS service";
    package = lib.mkPackageOption pkgs "dufs" { };

    stateDir = lib.mkOption {
      type = types.path;
      default = "/var/lib/dufs";
    };

    host = lib.mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = types.port;
      default = 5000;
    };

    environment = lib.mkOption {
      type = types.attrsOf types.str;
      default = { };
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    openFirewall = lib.mkOption {
      type = types.bool;
      default = false;
    };

    compressionLevel = lib.mkOption {
      type = types.enum [
        "none"
        "low"
        "medium"
        "high"
      ];
      default = "low";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = lib.mkIf cfg.openFirewall { allowedTCPPorts = [ cfg.port ]; };

    systemd.services.dufs = {
      description = "A file server that supports static serving, uploading, searching, accessing control, webdav...";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        DUFS_SERVE_PATH = cfg.stateDir;
        DUFS_BIND = cfg.host;
        DUFS_PORT = toString cfg.port;
        DUFS_COMPRESS = cfg.compressionLevel;

        # WIP
        DUFS_ALLOW_ALL = "true";
      } // cfg.environment;

      serviceConfig = {
        DynamicUser = true;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${lib.getExe cfg.package} ${cfg.stateDir}";
        PrivateTmp = true;
        StateDirectory = "dufs";
        WorkingDirectory = cfg.stateDir; # Must be set. Strange, this in theory should be implied by DynamicUser=.
      };
    };
  };
}
