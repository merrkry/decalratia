{ config, ... }:
{
  security.acme.certs =
    let
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare-token".path;
      reloadServices = [ "nginx.service" ];
    in
    {
      # NOTE: Consider wildcards, especially for internal services.
      "karanohako.tsubasa.moe" = {
        domain = "karanohako.tsubasa.moe";
        extraDomainNames = [ "llm.tsubasa.moe" ];
        inherit dnsProvider environmentFile reloadServices;
      };
      "karanohako.tsubasa.one" = {
        domain = "karanohako.tsubasa.one";
        extraDomainNames = [
          "couchdb.tsubasa.one"
          "dufs.tsubasa.one"
          "tavern.tsubasa.one"
        ];
        inherit dnsProvider environmentFile reloadServices;
      };
    };

  services.nginx = {
    enable = true;
  };

  sops.secrets = {
    "acme/cloudflare-token" = { };
  };

  users.users.nginx.extraGroups = [ "acme" ];
}
