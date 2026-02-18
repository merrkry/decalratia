{
  config,
  helpers,
  pkgs,
  ...
}:
let
  domainName = "id.tsubasa.moe";
  certDomain = "ilmenite.tsubasa.moe";
  port = helpers.servicePorts.kanidm;
in
{
  services = {
    kanidm = {
      package = pkgs.kanidm_1_9;

      server = {
        enable = true;
        settings = {
          tls_chain = "${config.security.acme.certs.${certDomain}.directory}/fullchain.pem";
          tls_key = "${config.security.acme.certs.${certDomain}.directory}/key.pem";
          bindaddress = "[::1]:${toString port}";
          domain = domainName;
          origin = "https://${domainName}";
          http_client_address_info = {
            x-forward-for = [
              "127.0.0.1"
              "::1"
            ];
          };
          online_backup = {
            path = "/var/lib/kanidm/backup";
            schedule = "0 0 * * *";
          };
        };
      };

      client = {
        enable = true;
        settings = {
          uri = "https://${domainName}";
        };
      };
    };

    nginx.virtualHosts.${domainName} = {
      forceSSL = true;
      useACMEHost = certDomain;
      locations."/" = {
        proxyPass = "https://[::1]:${toString port}";
      };
    };
  };

  users.users."kanidm".extraGroups = [ "acme" ];
}
