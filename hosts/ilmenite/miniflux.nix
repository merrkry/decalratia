{ config, lib, ... }:
let
  domainName = "miniflux.tsubasa.moe";
  certDomain = "ilmenite.tsubasa.moe";
  port = lib.servicePorts.miniflux;
in
{
  services = {
    miniflux = {
      enable = true;
      createDatabaseLocally = true;
      config = {
        BASE_URL = "https://${domainName}";

        CREATE_ADMIN = 0;
        DISABLE_LOCAL_AUTH = 1;

        LISTEN_ADDR = "[::1]:${toString port}";

        OAUTH2_PROVIDER = "oidc";
        OAUTH2_CLIENT_ID = "miniflux";
        OAUTH2_REDIRECT_URL = "https://${domainName}/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://id.tsubasa.moe/oauth2/openid/miniflux";
        OAUTH2_USER_CREATION = 1;

        RUN_MIGRATIONS = 1;
      };
    };

    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = certDomain;
      locations."/" = {
        proxyPass = "http://localhost:${toString port}";
      };
    };
  };

  sops.secrets."miniflux" = { };

  systemd.services.miniflux.serviceConfig.EnvironmentFile = config.sops.secrets."miniflux".path;
}
