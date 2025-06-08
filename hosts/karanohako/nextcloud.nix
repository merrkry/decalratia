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
      package = pkgs.nextcloud31;
      config = {
        adminpassFile = config.sops.secrets."nextcloud/adminPass".path;
        dbtype = "pgsql";
      };
      configureRedis = true;
      database.createLocally = true;
      hostName = domainName;
      https = true;
      maxUploadSize = "16G";
      # https://docs.nextcloud.com/server/30/admin_manual/installation/server_tuning.html
      phpOptions = {
        "opcache.jit" = "1255";
        "opcache.jit_buffer_size" = "8M";
        "opcache.interned_strings_buffer" = "16";
      };
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
