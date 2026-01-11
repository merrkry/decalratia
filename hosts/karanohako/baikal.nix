_:
let
  domain = "baikal.tsubasa.one";
in
{
  services = {
    baikal = {
      enable = true;
      virtualHost = domain;
    };

    nginx = {
      virtualHosts.${domain} = {
        forceSSL = true;
        useACMEHost = "karanohako.tsubasa.one";
      };
    };
  };
}
