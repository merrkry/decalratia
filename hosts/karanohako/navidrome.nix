{ config, lib, ... }:
let
  domainName = "navidrome.merrkry.com";
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
    nginx.virtualHosts.${domainName} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.navidrome.settings.Port}";
      };
    };

    navidrome = {
      enable = true;
      settings = {
        Address = "127.0.0.1";
        Port = 4533;
      };
    };
  };
}
