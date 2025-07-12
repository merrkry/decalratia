{ config, helpers, ... }:
{
  services = {
    dufs = {
      enable = true;
      port = helpers.servicePorts.dufs;
      extraConfigFile = config.sops.secrets."dufs".path;
    };

    nginx.virtualHosts."dufs.tsubasa.one" = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      locations."/" = {
        proxyPass = "http://unix:${config.services.dufs.socket}";
        extraConfig = ''
          client_max_body_size 0;
        '';
      };
    };
  };

  sops.secrets = {
    "dufs" = {
      owner = config.services.dufs.user;
      restartUnits = [ "dufs.service" ];
    };
  };

  systemd.services.dufs.after = [ "sops-install-secrets.service" ];
}
