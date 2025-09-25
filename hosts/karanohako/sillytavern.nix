{
  helpers,
  ...
}:
let
  port = helpers.servicePorts.sillytavern;
in
{
  services = {
    sillytavern = {
      enable = true;
      listenAddressIPv4 = "127.0.0.1";
      listenAddressIPv6 = "::1";
      inherit port;
      # It is much easier to maintain by simly keeping this mutable within data dir.
      configFile = "/var/lib/SillyTavern/sillytavern.yaml";
    };

    nginx.virtualHosts."tavern.tsubasa.one" = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
      };
    };
  };
}
