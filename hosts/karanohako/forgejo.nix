{
  config,
  helpers,
  lib,
  ...
}:
let
  srv = config.services.forgejo.settings.server;
in
{
  services.nginx = {
    virtualHosts.${srv.DOMAIN} = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      extraConfig = ''
        client_max_body_size 1G;
      '';
      locations."/".proxyPass = "http://unix:${srv.HTTP_ADDR}";
    };
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      repository = {
        DEFAULT_BRANCH = "master";
        DEFAULT_PRIVATE = "private";
        DISABLE_STARS = true;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      server = {
        DOMAIN = "git.tsubasa.one";
        HTTP_PORT = helpers.servicePorts.forgejo;
        PROTOCOL = "http+unix";
        ROOT_URL = "https://${srv.DOMAIN}/";
        SSH_PORT = lib.head config.services.openssh.ports;
      };
    };
  };
}
