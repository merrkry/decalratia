{
  config,
  lib,
  pkgs,
  ...
}:
let
  domainName = "nextcloud.merrkry.com";
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
    nextcloud = {
      enable = true;
      package = pkgs.nextcloud30;
      config = {
        adminpassFile = config.sops.secrets."nextcloud/adminPass".path;
        dbtype = "pgsql";
      };
      configureRedis = true;
      database.createLocally = true;
      extraApps = {
        inherit (config.services.nextcloud.package.packages.apps)
          calendar
          contacts
          mail
          tasks
          ;
      };
      hostName = domainName;
      https = true;
      maxUploadSize = "16G";
    };
    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      enableACME = true;
    };
  };

  sops.secrets = {
    "acme/cloudflare-token" = { };
    "nextcloud/adminPass".owner = "nextcloud";
  };
}
