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
      enableServer = true;
      enableClient = true;
      enablePam = false;

      package = pkgs.kanidm_1_6;

      serverSettings = {
        tls_chain = "${config.security.acme.certs.${certDomain}.directory}/fullchain.pem";
        tls_key = "${config.security.acme.certs.${certDomain}.directory}/key.pem";
        bindaddress = "[::1]:${toString port}";
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
      forceSSL = true;
      useACMEHost = certDomain;
      locations."/" = {
        proxyPass = "https://[::1]:${toString port}";
      };
    };
  };

  users.users."kanidm".extraGroups = [ "acme" ];
}
