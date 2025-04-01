{
  config,
  lib,
  pkgs,
  ...
}:
let
  domainName = "id.tsubasa.moe";
in
{
  networking.firewall.allowedTCPPorts = [ 443 ];

  security.acme.certs.${domainName} = {
    postRun = "systemctl --no-block restart kanidm.service";
    domain = domainName;
    dnsProvider = "cloudflare";
    environmentFile = config.sops.secrets."acme/cloudflare-token".path;
    group = "nginx";
    webroot = lib.mkForce null;
  };

  services = {
    kanidm = {
      enableServer = true;
      enableClient = true;
      enablePam = false;

      package = pkgs.kanidm_1_5;

      serverSettings = {
        tls_chain = "${config.security.acme.certs.${domainName}.directory}/fullchain.pem";
        tls_key = "${config.security.acme.certs.${domainName}.directory}/key.pem";
        bindaddress = "[::1]:${toString config.lib.ports.kanidm}";
        domain = domainName;
        origin = "https://${domainName}";
        trust_x_forward_for = true;
        online_backup = {
          path = "/var/lib/kanidm/backup";
          schedule = "0 0 * * *";
        };
      };
      clientSettings = {
        uri = "https://${domainName}";
      };
    };

    nginx.virtualHosts.${domainName} = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://[::1]:${toString config.lib.ports.kanidm}";
      };
    };
  };

  users.users."kanidm".extraGroups = [ "nginx" ];
}
