{ config, ... }:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "postgresql";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = config.lib.ports.vaultwarden;
      DATABASE_URL = "postgres:///vaultwarden?host=/run/postgresql";
    };
  };

  systemd.services.vaultwarden = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.postgresql.ensureDatabases = [ "vaultwarden" ];
  services.postgresql.ensureUsers = [
    {
      name = "vaultwarden";
      ensureDBOwnership = true;
    }
  ];
}
