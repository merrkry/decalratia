{ config, lib, ... }:
let
  domain = "m.tsubasa.moe";
in
{
  sops.secrets = {
    "mailserver/users/mastodon".owner = config.services.mastodon.user;
    "mastodon-s3".owner = config.services.mastodon.user;
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
      passwordFile = config.sops.secrets."mailserver/users/mastodon".path;
      fromAddress = "mastodon@tsubasa.moe";
    };

    elasticsearch.host = "127.0.0.1";

    mediaAutoRemove.olderThanDays = 14;

    extraConfig = {
      WEB_DOMAIN = domain;
      AUTHORIZED_FETCH = "true";
    };

    extraEnvFiles = [ config.sops.secrets."mastodon-s3".path ];
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
