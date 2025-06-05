{ config, ... }:
let
  domain = "m.tsubasa.moe";
in
{
  sops.secrets = {
    "mastodon/envFile".owner = config.services.mastodon.user;
    "mastodon/smtpPasswd".owner = config.services.mastodon.user;
  };

  services = {
    mastodon = {
      enable = true;

      localDomain = domain;

      enableUnixSocket = true;
      configureNginx = true;

      streamingProcesses = 3;

      smtp = {
        createLocally = false;

        authenticate = true;
        host = "mail.tsubasa.moe";
        port = 587;
        user = "mastodon@tsubasa.moe";
        passwordFile = config.sops.secrets."mastodon/smtpPasswd".path;
        fromAddress = "mastodon@tsubasa.moe";
      };

      elasticsearch.host = "127.0.0.1";

      mediaAutoRemove.olderThanDays = 14;

      extraConfig = {
        WEB_DOMAIN = domain;
        AUTHORIZED_FETCH = "true";

        OIDC_ENABLED = "true";
        OIDC_DISPLAY_NAME = "id.tsubasa.moe";
        OIDC_ISSUER = "https://id.tsubasa.moe/oauth2/openid/mastodon";
        OIDC_DISCOVERY = "true";
        OIDC_SCOPE = "openid,profile,email";
        OIDC_UID_FIELD = "preferred_username";
        OIDC_REDIRECT_URI = "https://${domain}/auth/auth/openid_connect/callback";
        OIDC_SECURITY_ASSUME_EMAIL_IS_VERIFIED = "true";
        OIDC_CLIENT_ID = "mastodon";
        OIDC_USE_PKCE = "true";
        # https://github.com/mastodon/mastodon/issues/20144
        # https://github.com/mastodon/mastodon/pull/16221#issuecomment-2440825500
        ALLOW_UNSAFE_AUTH_PROVIDER_REATTACH = "true";
      };

      extraEnvFiles = [ config.sops.secrets."mastodon/envFile".path ];
    };

    nginx.virtualHosts.${config.services.mastodon.localDomain} = {
      enableACME = false;
      useACMEHost = "ilmenite.tsubasa.moe";
    };

    opensearch.enable = true;
  };
}
