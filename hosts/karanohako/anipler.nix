{
  lib,
  config,
  inputs,
  helpers,
  pkgs,
  ...
}:
let
  domain = "anipler.tsubasa.one";
  port = helpers.servicePorts.anipler;
in
{
  imports = [ inputs.anipler.nixosModules.default ];

  services = {
    anipler = {
      inherit port;
      enable = true;
      env = {
        ANIPLER_RSYNC_SPEED_LIMIT = "2048"; # 2 MB/s
        ANIPLER_SEEDBOX_SSH_KEY = config.sops.secrets."anipler/ssh-key".path;
        RUST_LOG = "info,anipler=debug";
      };
      envFile = config.sops.secrets."anipler/env".path;
    };

    nginx.virtualHosts.${domain} = {
      forceSSL = true;
      useACMEHost = "karanohako.tsubasa.one";
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString port}";
      };
    };
  };

  sops.secrets = {
    "anipler/env" = {
      owner = config.services.anipler.user;
    };
    "anipler/ssh-key" = {
      owner = config.services.anipler.user;
    };
  };

  users.users.${config.services.anipler.user}.openssh.authorizedKeys.keys = helpers.sshKeys.trusted;
}
