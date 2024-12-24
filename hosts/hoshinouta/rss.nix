{ config, ... }:
{
  sops.secrets."miniflux/adminCredentials" = { };

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "127.0.0.1:${toString config.lib.ports.miniflux}";
    };
    adminCredentialsFile = config.sops.secrets."miniflux/adminCredentials".path;
  };

  virtualisation.oci-containers.containers."rsshub" = {
    image = "diygod/rsshub:chromium-bundled";
    autoStart = true;
    ports = [ "127.0.0.1:${toString config.lib.ports.rsshub}:1200" ];
    volumes = [ "${config.services.redis.servers."rsshub".unixSocket}:/var/run/redis.sock" ];
    environment = {
      NODE_ENV = "production";
      CACHE_TYPE = "redis";
      REDIS_URL = "unix:///var/run/redis.sock";
    };
  };

  services.redis.servers."rsshub" = {
    enable = true;
    user = "root";
  };
}
