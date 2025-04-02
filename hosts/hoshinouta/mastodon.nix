{ config, lib, ... }:
let
  domain = "m.tsubasa.moe";
in
{
  sops.secrets = {
    "mailserver/users/mastodon/raw".owner = config.services.mastodon.user;
    "mastodon".owner = config.services.mastodon.user;
  };

  services.opensearch.enable = true;

  services.mastodon = {
    enable = true;

    localDomain = domain;

    enableUnixSocket = true;
    configureNginx = false;

    streamingProcesses = 3;

    smtp = {
      createLocally = false;

      authenticate = true;
      host = "mail.tsubasa.moe";
      port = 587;
      user = "mastodon@tsubasa.moe";
      passwordFile = config.sops.secrets."mailserver/users/mastodon/raw".path;
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

    extraEnvFiles = [ config.sops.secrets."mastodon".path ];
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/web-apps/mastodon.nix
  services.nginx =
    let
      cfg = config.services.mastodon;
    in
    {
      virtualHosts."${domain}" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 443;
            ssl = false;
          }
        ];

        root = "${cfg.package}/public/";

        # let cloudflared handle TLS
        forceSSL = false;
        enableACME = false;

        locations."/system/".alias = "/var/lib/mastodon/public-system/";

        locations."/" = {
          tryFiles = "$uri @proxy";
        };

        locations."@proxy" = {
          proxyPass = (
            if cfg.enableUnixSocket then
              "http://unix:/run/mastodon-web/web.socket"
            else
              "http://127.0.0.1:${toString cfg.webPort}"
          );
          proxyWebsockets = true;

          extraConfig = ''
            proxy_set_header X-Forwarded-Proto https;
          '';
        };

        locations."/api/v1/streaming/" = {
          proxyPass = "http://mastodon-streaming";
          proxyWebsockets = true;
        };
      };

      upstreams.mastodon-streaming = {
        extraConfig = ''
          least_conn;
        '';
        servers = builtins.listToAttrs (
          map (i: {
            name = "unix:/run/mastodon-streaming/streaming-${toString i}.socket";
            value = { };
          }) (lib.range 1 cfg.streamingProcesses)
        );
      };
    };

  users.groups.${config.services.mastodon.group}.members = [ config.services.nginx.user ];
}
