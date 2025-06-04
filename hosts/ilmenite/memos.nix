{
  config,
  lib,
  pkgs,
  ...
}:
let
  domainName = "memos.tsubasa.moe";
  certDomain = "ilmenite.tsubasa.moe";
  port = lib.servicePorts.memos;
  dataDir = "/var/lib/memos";
in
{
  sops.secrets."memogram" = { };

  systemd.services = {
    "memos" = {
      after = [
        "network.target"
        "postgresql.service"
      ];
      requires = [
        "network-online.target"
        "postgresql.service"
      ];
      environment = {
        MEMOS_MODE = "prod";
        MEMOS_ADDR = "127.0.0.1";
        MEMOS_PORT = toString port;
        MEMOS_DATA = dataDir;
        MEMOS_DRIVER = "postgres";
        MEMOS_DSN = "postgres:///memos?host=/run/postgresql";
      };

      serviceConfig = {
        Type = "exec";
        DynamicUser = true;
        User = "memos";
        Group = "memos";
        WorkingDirectory = dataDir;
        StateDirectory = "memos";
        ExecStart = "${pkgs.memos}/bin/memos";
      };

      wantedBy = [ "multi-user.target" ];
    };

    "memogram" = {
      after = [
        "network.target"
        "memos.service"
      ];
      requires = [
        "network-online.target"
        "memos.service"
      ];
      environment = {
        # EXTREMELY BUGGY
        # `127.0.0.1` in memoes plugs `localhost` here is the only working combination found
        SERVER_ADDR = "dns:localhost:${toString port}";
        ALLOWED_USERNAMES = "merrkry";
      };

      serviceConfig = {
        Type = "exec";
        DynamicUser = true;
        User = "memogram";
        Group = "memogram";
        WorkingDirectory = "/var/lib/memogram";
        StateDirectory = "memogram";
        ExecStart = lib.getExe pkgs.memogram;
        EnvironmentFile = config.sops.secrets."memogram".path;
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

  services = {
    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = certDomain;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };

    postgresql = {
      ensureDatabases = [ "memos" ];
      ensureUsers = [
        {
          name = "memos";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
