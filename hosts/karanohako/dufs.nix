{ config, lib, ... }:
{
  services = {
    dufs = {
      enable = true;
      port = lib.servicePorts.dufs;
    };

    nginx.virtualHosts."dufs.tsubasa.one" = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.dufs.port}";
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };
}
