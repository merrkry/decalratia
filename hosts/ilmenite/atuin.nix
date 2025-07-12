{ config, helpers, ... }:
{
  services.atuin = {
    enable = true;
    openRegistration = true;
    port = helpers.servicePorts.atuin;
  };

  services.nginx.virtualHosts."atuin.tsubasa.moe" = {
    forceSSL = true;
    useACMEHost = "ilmenite.tsubasa.moe";
    locations."/".proxyPass = "http://localhost:${toString config.services.atuin.port}";
  };
}
