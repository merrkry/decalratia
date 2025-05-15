{ config, ... }:
{
  security.acme.certs."karanohako.tsubasa.moe" = {
    domain = "karanohako.tsubasa.moe";
    extraDomainNames = [ "llm.tsubasa.moe" ];
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets."acme/cloudflare-token".path;
    reloadServices = [ "nginx.service" ];
  };

  services.nginx = {
    enable = true;
  };

  sops.secrets = {
    "acme/cloudflare-token" = { };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
