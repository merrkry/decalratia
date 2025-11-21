{
  helpers,
  ...
}:
let
  port = helpers.servicePorts.couchdb;
in
{
  services = {
    couchdb = {
      enable = true;
      inherit port;
    };

    nginx.virtualHosts."couchdb.tsubasa.one" = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
        extraConfig = ''
          proxy_redirect off;
          proxy_buffering off;
        '';
      };
    };
  };
}
