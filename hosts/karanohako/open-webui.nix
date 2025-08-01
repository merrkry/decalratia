{
  config,
  helpers,
  lib,
  pkgs,
  ...
}:
let
  serviceName = "open-webui";
  domainName = "llm.tsubasa.moe";
in
{
  services = {
    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.moe";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.open-webui.port}";
        proxyWebsockets = true;
      };
    };

    open-webui = {
      enable = true;
      environment = {
        # We need this to let environment variable overwrite persisted config in db.
        # According to code, if this is set to false while related env var is not set,
        # open-webui will use default value instead of read from db.
        # Not so sure if there's any thing we want to keep, so better keep this unset unless necessary.
        # https://github.com/open-webui/open-webui/blob/63256136ef8322210c01c2bb322097d1ccfb8c6f/backend/open_webui/config.py#L163-L174
        # ENABLE_PERSISTENT_CONFIG = "False";

        WEBUI_URL = "https://${domainName}";
        ENABLE_LOGIN_FORM = "False";
        VECTOR_DB = "pgvector";
        ENABLE_OAUTH_SIGNUP = "True";
        OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
        OAUTH_CLIENT_ID = "open-webui";
        OPENID_PROVIDER_URL = "https://id.tsubasa.moe/oauth2/openid/${serviceName}/.well-known/openid-configuration";
        DATABASE_URL = "postgres:///${serviceName}?host=/run/postgresql";
      };
      environmentFile = config.sops.secrets."open-webui".path;
      port = helpers.servicePorts.open-webui;
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
      extensions = ps: with ps; [ pgvector ];
    };
  };

  sops.secrets = {
    "open-webui" = { };
  };

  systemd.services = {
    ${serviceName} = {
      after = [ "postgresql.service" ];
      requires = [ "postgresql.service" ];
      path = [ pkgs.ffmpeg ];
    };

    postgresql.serviceConfig.ExecStartPost =
      let
        sqlFile = pkgs.writeText "open-webui-pgvector-setup.sql" ''
          CREATE EXTENSION IF NOT EXISTS vector;
        '';
      in
      [
        ''
          ${lib.getExe' config.services.postgresql.package "psql"} -d "${serviceName}" -f "${sqlFile}"
        ''
      ];
  };
}
