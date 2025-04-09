{ config, pkgs, ... }:
{
  nixpkgs = {
    config.permittedInsecurePackages = [ "olm-3.2.16" ];
  };

  sops.secrets = {
    "matrix-synapse/extra-config".owner = config.systemd.services.matrix-synapse.serviceConfig.User;
    "matrix-synapse/signing-key".owner = config.systemd.services.matrix-synapse.serviceConfig.User;
    "matrix-synapse/mautrix-telegram".owner = config.systemd.services.matrix-synapse.serviceConfig.User;
    "matrix-synapse/oidc-client-secret".owner =
      config.systemd.services.matrix-synapse.serviceConfig.User;
    "mautrix-telegram" = { };
  };

  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;

    settings = {
      server_name = "tsubasa.moe";
      public_baseurl = "https://matrix.tsubasa.moe";
      signing_key_path = config.sops.secrets."matrix-synapse/signing-key".path;

      enable_registration = true;
      registration_requires_token = true;

      dynamic_thumbnails = true;

      app_service_config_files = [ config.sops.secrets."matrix-synapse/mautrix-telegram".path ];

      media_store_path = "/var/lib/matrix-synapse/media_store";

      listeners = [
        {
          bind_addresses = [ "127.0.0.1" ];
          port = config.lib.ports.matrix-synapse;
          tls = false;
          type = "http";
          x_forwarded = true;
          resources = [
            {
              compress = true;
              names = [
                "client"
                "federation"
              ];
            }
          ];
        }
      ];

      media_retention = {
        remote_media_lifetime = "14d";
      };
      forgotten_room_retention_period = "28d";

      oidc_providers = [
        {
          idp_id = "kanidm";
          idp_name = "id.tsubasa.moe";
          issuer = "https://id.tsubasa.moe/oauth2/openid/synapse";
          client_id = "synapse";
          client_secret_path = config.sops.secrets."matrix-synapse/oidc-client-secret".path;
          scopes = [
            "email"
            "openid"
            "profile"
          ];
          allow_existing_users = true;
          backchannel_logout_enabled = true; # not sure if supported by kanidm
          user_mapping_provider.config = {
            confirm_localpart = true;
            localpart_template = "{{ user.preferred_username }}";
            display_name_template = "{{ user.name }}";
            email_template = "{{ user.email }}";
          };
        }
      ];
    };

    extraConfigFiles = [ config.sops.secrets."matrix-synapse/extra-config".path ];

    configureRedisLocally = true;
  };

  services.nginx.virtualHosts."matrix.tsubasa.moe" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 443;
      }
    ];
    locations."~ ^(/_matrix|/_synapse/client)" = {
      recommendedProxySettings = false; # handle manually
      proxyPass = "http://127.0.0.1:${toString config.lib.ports.matrix-synapse}";
      extraConfig = ''
        # pass the headers from cloudflared directly
        # proxy_set_header X-Forwarded-For $remote_addr;
        # proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host;

        client_max_body_size 50M;

        proxy_http_version 1.1;
      '';
    };
    locations."/" = {
      root = pkgs.cinny;
      # https://github.com/cinnyapp/cinny/blob/dev/contrib/nginx/cinny.domain.tld.conf
      extraConfig =
        ''
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
          add_header Content-Security-Policy "frame-ancestors 'self'" always;
        ''
        + ''
          rewrite ^/config.json$ /config.json break;
          rewrite ^/manifest.json$ /manifest.json break;

          rewrite ^.*/olm.wasm$ /olm.wasm break;
          rewrite ^/sw.js$ /sw.js break;
          rewrite ^/pdf.worker.min.js$ /pdf.worker.min.js break;

          rewrite ^/public/(.*)$ /public/$1 break;
          rewrite ^/assets/(.*)$ /assets/$1 break;

          rewrite ^(.+)$ /index.html break;
        '';
    };
  };

  services.mautrix-telegram = {
    enable = true;
    environmentFile = config.sops.secrets."mautrix-telegram".path;
    settings = {
      homeserver = {
        address = "http://127.0.0.1:${toString config.lib.ports.matrix-synapse}";
        domain = config.services.matrix-synapse.settings.server_name;
      };
      appservice = {
        address = "http://127.0.0.1:${toString config.lib.ports.mautrix-telegram}";
        database = "postgres:///mautrix-telegram?host=/run/postgresql";
        hostname = "127.0.0.1";
        port = config.lib.ports.mautrix-telegram;
      };
      bridge = {
        displayname_template = "{displayname}";
        delivery_error_reports = true;
        incoming_bridge_error_reports = true;
        relay_user_distinguishers = [ ];
        animated_sticker = {
          target = "webp";
          convert_from_webm = true;
        };
        state_event_formats = {
          join = "";
          leave = "";
          name_change = "";
        };
        permissions = {
          "*" = "relaybot";
          "@merrkry:tsubasa.moe" = "admin";
        };
        relaybot = {
          authless_portals = false;
        };
      };
      telegram.force_refresh_interval_seconds = 300;
    };
    registerToSynapse = false; # handle registration file manually
  };

  systemd.services.mautrix-telegram.serviceConfig.RuntimeMaxSec = 900;
}
