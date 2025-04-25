{ config, lib, ... }:
{
  services.atuin = {
    enable = true;
    openRegistration = true;
    port = lib.servicePorts.atuin;
  };

  services.nginx.virtualHosts."atuin.tsubasa.moe" = {
    forceSSL = true;
    useACMEHost = "ilmenite.tsubasa.moe";
    locations."/".proxyPass = "http://localhost:${toString config.services.atuin.port}";
  };
}
