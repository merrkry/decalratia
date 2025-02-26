{
  config,
  lib,
  pkgs,
  ...
}:
let
  dataDir = "/var/lib/memos";
in
{
  sops.secrets."memogram" = { };

  # nixpkgs version is extremely out of date
  # https://github.com/NixOS/nixpkgs/pull/304264

  virtualisation.oci-containers.containers."memos" = {
    image = "neosmemo/memos:stable";
    autoStart = true;
    volumes = [
      # may need to manually create before first run
      "${dataDir}:/var/opt/memos"
    ];
    ports = [ "127.0.0.1:${toString config.lib.ports.memos}:5230" ];
    extraOptions = [ "--pull=newer" ];
  };

  # systemd.services."memos" = {
  #   after = [
  #     "network.target"
  #     "postgresql.service"
  #   ];
  #   requires = [
  #     "network-online.target"
  #     "postgresql.service"
  #   ];
  #   environment = {
  #     MEMOS_MODE = "prod";
  #     MEMOS_ADDR = "127.0.0.1";
  #     MEMOS_PORT = toString config.lib.ports.memos;
  #     MEMOS_DATA = dataDir;
  #     MEMOS_DRIVER = "postgres";
  #     MEMOS_DSN = "postgres:///memos?host=/run/postgresql";
  #   };

  #   serviceConfig = {
  #     Type = "exec";
  #     DynamicUser = true;
  #     User = "memos";
  #     Group = "memos";
  #     WorkingDirectory = dataDir;
  #     # creates the directory under /var/lib
  #     StateDirectory = "memos";
  #     # UMask = "0027";
  #     ExecStart = "${pkgs.memos}/bin/memos";
  #   };

  #   wantedBy = [ "multi-user.target" ];
  # };

  systemd.services."memogram" = {
    after = [
      "network.target"
      # "memos.service"/"podman-memos.service"
    ];
    requires = [
      "network-online.target"
      # "memos.service"/"podman-memos.service"
    ];
    environment = {
      SERVER_ADDR = "dns:localhost:${toString config.lib.ports.memos}";
    };

    serviceConfig = {
      Type = "exec";
      DynamicUser = true;
      User = "memogram";
      Group = "memogram";
      WorkingDirectory = "/var/lib/memogram";
      StateDirectory = "memogram";
      ExecStart = lib.getExe pkgs.memogram;
      EnvironmentFile = config.sops.secrets."memogram".path;
    };

    wantedBy = [ "multi-user.target" ];
  };

  services.postgresql.ensureDatabases = [ "memos" ];
  services.postgresql.ensureUsers = [
    {
      name = "memos";
      ensureDBOwnership = true;
    }
  ];
}
