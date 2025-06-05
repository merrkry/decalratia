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
      "tsubasa.moe"
      "atuin.tsubasa.moe"
      "cache.tsubasa.moe" # atticd
      "id.tsubasa.moe" # kanidm
      "m.tsubasa.moe" # mastodon
      "mail.tsubasa.moe" # nixos-mailserver
      "matrix.tsubasa.moe" # synapse
      "memos.tsubasa.moe"
      "miniflux.tsubasa.moe"
      "vault.tsubasa.moe" # vaultwarden
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
