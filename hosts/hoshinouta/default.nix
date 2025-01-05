{
  inputs,
  lib,
  user,
  ...
}:
{
  imports = (lib.mkModulesList ./.) ++ [ "${inputs.secrets}/hoshinouta/nixos.nix" ];

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

  users.users = {
    ${user} = {
      hashedPassword = "$2b$05$osXmrqxL1gCYfTPfQW9N3eHVygTjjC8T5yWlYuiyHTiOPhZ/eWinC";
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFile = "${inputs.secrets}/hoshinouta/secrets.yaml";
  };

  time.timeZone = "Europe/Vienna";

  services.nginx.enable = true;

  lib.ports = {
    memos = 5230;
    miniflux = 10001;
    rsshub = 10002;
    matrix-synapse = 10003;
    mautrix-telegram = 29317; # This should match the app service registration file, which is in secrets
    vaultwarden = 10005;
    mastodon = 10007;
  };
}
