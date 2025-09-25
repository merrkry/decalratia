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
  workDir = "/var/lib/${serviceName}";
  port = helpers.servicePorts.${serviceName};
in
{
  networking.firewall.interfaces."podman0".allowedTCPPorts = [ 5432 ];

  services = {
    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.moe";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        proxyWebsockets = true; # TODO: Do I still need this?
      };
    };

    postgresql = {
      enable = true;
      enableTCPIP = true;
      authentication = ''
        host open-webui open-webui 10.88.0.0/16 md5
      '';
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
    ${config.virtualisation.oci-containers.containers.${serviceName}.serviceName} = {
      after = [
        "postgresql.service"
        "sops-install-secrets.service"
      ];
      requires = [ "postgresql.service" ];
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

  virtualisation.oci-containers.containers.${serviceName} = {
    image = "ghcr.io/open-webui/open-webui:main";
    pull = "newer";

    # FIXME: use EITHER volume or /var/lib
    volumes = [ "open-webui:/app/backend/data" ];
    ports = [ "127.0.0.1:${toString port}:8080" ];
    # TODO: --userns=auto
    extraOptions = [
      "--add-host=host.docker.internal:host-gateway"
    ];

    environment = {
      # sync with services.open-webui for compatibility
      STATIC_DIR = "${workDir}/static";
      DATA_DIR = "${workDir}/data";
      HF_HOME = "${workDir}/hf_home";
      SENTENCE_TRANSFORMERS_HOME = "${workDir}/transformers_home";

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
    };
    environmentFiles = [ config.sops.secrets."open-webui".path ];
  };
}
