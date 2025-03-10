{ config, lib, ... }:
let
  serviceName = "atticd";
  domainName = "nix-cache.merrkry.com";
  port = 8080;
in
{
  nix.settings = {
    substituters = [
      "https://nix-community.cachix.org"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  security = {
    # Required for atticd-atticadm to work
    polkit.enable = true;

    acme.certs = {
      ${domainName} = {
        domain = domainName;
        dnsProvider = "cloudflare";
        environmentFile = config.sops.secrets."acme/cloudflare-token".path;
        group = "nginx";
        webroot = lib.mkForce null;
      };
    };
  };

  services = {
    atticd = {
      enable = true;

      environmentFile = config.sops.secrets."atticd/envFile".path;

      settings = {
        listen = "[::]:${toString port}";
        api-endpoint = "https://nix-cache.merrkry.com/";
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
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
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
    "acme/cloudflare-token" = { };
  };
}
