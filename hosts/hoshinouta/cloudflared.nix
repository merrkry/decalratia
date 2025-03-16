{ config, ... }:
{
  sops.secrets = {
    "cloudflared/hoshinouta0" = { };
    "cloudflared/hoshinouta1" = { };
  };

  services.cloudflared = {
    enable = true;
    # Managed viad web dashboard
    # It seems unnecessary to set default ingress field, but eval will fail without it
    tunnels = {
      # hoshinouta0 tsubasa.moe
      "2e3988cf-3e46-43e9-a981-65af2306c5a3" = {
        credentialsFile = config.sops.secrets."cloudflared/hoshinouta0".path;
        default = "http_status:404";
      };
      # hoshinouta1 merrkry.com
      "2541af10-f0d8-4418-b88a-0b90db81dcf3" = {
        credentialsFile = config.sops.secrets."cloudflared/hoshinouta1".path;
        default = "http_status:404";
      };
    };
  };
}
