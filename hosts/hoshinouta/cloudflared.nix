{ config, ... }:
{
  sops.secrets = {
    "cloudflared/hoshinouta0".owner = config.services.cloudflared.user;
    "cloudflared/hoshinouta1".owner = config.services.cloudflared.user;
  };

  services.cloudflared = {
    enable = true;
    # TODO: manage via web dashboard directly
    tunnels = {
      # hoshinouta0 tsubasa.moe
      "2e3988cf-3e46-43e9-a981-65af2306c5a3" = {
        credentialsFile = config.sops.secrets."cloudflared/hoshinouta0".path;
        default = "http_status:404";

        ingress = {
          "matrix.tsubasa.moe" = "http://127.0.0.1:443";
          "m.tsubasa.moe" = "http://127.0.0.1:443";
        };
      };

      # hoshinouta1 merrkry.com
      "2541af10-f0d8-4418-b88a-0b90db81dcf3" = {
        credentialsFile = config.sops.secrets."cloudflared/hoshinouta1".path;
        default = "http_status:404";

        ingress = {
          "memos.merrkry.com" = "http://127.0.0.1:${toString config.lib.ports.memos}";
          "miniflux.merrkry.com" = "http://127.0.0.1:${toString config.lib.ports.miniflux}";
          "rsshub.merrkry.com" = "http://127.0.0.1:${toString config.lib.ports.rsshub}";
          "vaultwarden.merrkry.com" = "http://127.0.0.1:${toString config.lib.ports.vaultwarden}";
        };
      };
    };
  };
}
