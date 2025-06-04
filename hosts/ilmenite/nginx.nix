{ config, ... }:
{
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };

  security.acme.certs."ilmenite.tsubasa.moe" = {
    domain = "ilmenite.tsubasa.moe";
    extraDomainNames = [
      "atuin.tsubasa.moe"
      "cache.tsubasa.moe"
      "id.tsubasa.moe"
      "memos.tsubasa.moe"
      "vault.tsubasa.moe"
    ];
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets."acme/cloudflare".path;
    reloadServices = [ "nginx.service" ];
  };

  services.nginx = {
    enable = true;
  };

  sops.secrets = {
    "acme/cloudflare" = { };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
