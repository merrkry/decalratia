{ config, lib, ... }:
let
  serviceName = "atticd";
  domainName = "cache.tsubasa.moe";
  port = lib.servicePorts.atticd;
in
{
  # required by atticd-atticadm
  security.polkit.enable = true;

  services = {
    atticd = {
      enable = true;

      environmentFile = config.sops.secrets."atticd/envFile".path;

      settings = {
        listen = "[::1]:${toString port}";
        api-endpoint = "https://${domainName}/";
        database.url = "postgres:///${serviceName}?host=/run/postgresql";
        chunking = {
          nar-size-threshold = 64 * 1024; # 64 KiB
          min-size = 16 * 1024; # 16 KiB
          avg-size = 64 * 1024; # 64 KiB
          max-size = 256 * 1024; # 256 KiB
        };
        garbage-collection = {
          interval = "1 day";
          default-retention-period = "1 month";
        };
        jwt = { };
      };
    };

    nginx = {
      enable = true;
      virtualHosts.${domainName} = {
        forceSSL = true;
        useACMEHost = "ilmenite.tsubasa.moe";
        locations."/" = {
          proxyPass = "http://localhost:${toString port}";
          extraConfig = ''
            client_max_body_size 16G;
          '';
        };
      };
    };

    postgresql = {
      ensureDatabases = [ serviceName ];
      ensureUsers = [
        {
          name = serviceName;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  sops.secrets = {
    "atticd/envFile" = { };
  };
}
