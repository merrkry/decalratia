{ config, ... }:
{
  security.acme.certs =
    let
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare-token".path;
      reloadServices = [ "nginx.service" ];
    in
    {
      "karanohako.tsubasa.moe" = {
        domain = "karanohako.tsubasa.moe";
        extraDomainNames = [ "llm.tsubasa.moe" ];
        inherit dnsProvider environmentFile reloadServices;
      };
      "karanohako.tsubasa.one" = {
        domain = "karanohako.tsubasa.one";
        extraDomainNames = [ "dufs.tsubasa.one" ];
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
