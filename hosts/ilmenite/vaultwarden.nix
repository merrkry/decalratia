{ lib, ... }:
let
  domainName = "vault.tsubasa.moe";
  certDomain = "ilmenite.tsubasa.moe";
  port = lib.servicePorts.vaultwarden;
in
{
  services = {
    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = certDomain;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
        proxyWebsockets = true;
      };
    };
    vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DOMAIN = "https://${domainName}";
        SIGNUPS_ALLOWED = false;
        ROCKET_ADDRESS = "::1";
        ROCKET_PORT = port;
        DATABASE_URL = "postgres:///vaultwarden?host=/run/postgresql";
      };
    };
  };

  systemd.services.vaultwarden = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.postgresql.ensureDatabases = [ "vaultwarden" ];
  services.postgresql.ensureUsers = [
    {
      name = "vaultwarden";
      ensureDBOwnership = true;
    }
  ];
}
