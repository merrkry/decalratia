{
  config,
  lib,
  pkgs,
  ...
}:
let
  serviceName = "open-webui";
  domainName = "open-webui.merrkry.com";
in
{
  # TODO: migrate to wildcard cert, unify cert management
  security.acme.certs = {
    ${domainName} = {
      domain = domainName;
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare-token".path;
      group = "nginx";
      webroot = lib.mkForce null;
    };
  };

  services = {
    nginx.virtualHosts.${domainName} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.open-webui.port}";
        proxyWebsockets = true;
      };
    };
    open-webui = {
      enable = true;
      package = pkgs.unstable.open-webui;
      environment = rec {
        DATABASE_URL = "postgres:///${serviceName}?host=/run/postgresql";
        ENABLE_WEBSOCKET_SUPPORT = "True";
        WEBSOCKET_MANAGER = "redis";
        WEBSOCKET_REDIS_URL = "unix://${config.services.redis.servers.${serviceName}.unixSocket}";
        REDIS_URL = WEBSOCKET_REDIS_URL;
        WEBUI_AUTH = "False";
      };
      # port = ; TODO: unify port management
    };
    postgresql = {
      enable = true;
      ensureUsers = [
        {
          name = serviceName;
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ serviceName ];
    };
    redis.servers.${serviceName} = {
      enable = true;
      user = "open-webui";
    };
  };

  systemd.services.${serviceName} = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };
}
