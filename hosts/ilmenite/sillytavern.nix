{
  helpers,
  lib,
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
      # It is much easier to maintain by simply keeping this mutable within data dir.
      configFile = "/var/lib/SillyTavern/sillytavern.yaml";
    };

    nginx.virtualHosts."tavern.tsubasa.one" = {
      onlySSL = true; # no redirection on 80
      useACMEHost = "ilmenite.tsubasa.one";
      locations."/" = {
        proxyPass = "http://[::1]:${toString port}";
      };
      listen = lib.mkForce [
        {
          addr = "100.82.254.71";
          port = 443;
          ssl = true;
        }
      ];
    };
  };
}
