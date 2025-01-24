{ config, lib, ... }:
let
  serviceName = "grafana";
  domainName = "grafana.merrkry.com";
in
{
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
    grafana = {
      enable = true;
      settings = {
        database = {
          host = "/run/postgresql";
          name = serviceName;
          type = "postgres";
          user = serviceName;
        };

        server = {
          http_addr = "127.0.0.1";
          http_port = config.lib.ports.grafana;
          enforce_domain = true;
          enable_gzip = true;
          domain = domainName;
        };

        analytics.reporting_enabled = false;
      };
    };

    nginx.virtualHosts.${domainName} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.lib.ports.grafana}";
        proxyWebsockets = true;
      };
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

    prometheus = {
      enable = true;
      port = config.lib.ports.prometheus;
      scrapeConfigs = [
        {
          job_name = "chrysalis";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
        };
      };
    };
  };

  sops.secrets = {
    "acme/cloudflare-token" = { };
  };

  systemd.services = {
    ${serviceName} = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
    };
  };
}
