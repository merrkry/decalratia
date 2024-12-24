{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.base.ssh;
in
{
  options.profiles.base.ssh = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
    hostKeysDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/ssh";
      description = "Base directory where the host keys are generated and stored.";
    };
  };

  config = lib.mkIf cfg.enable {

    security.pam = {
      services.sudo.sshAgentAuth = true;
      sshAgentAuth.enable = true;
    };
    services = {
      fail2ban.enable = true;
      openssh = {
        enable = true;
        hostKeys = lib.mkForce [
          {
            bits = 4096;
            path = "${cfg.hostKeysDirectory}/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            path = "${cfg.hostKeysDirectory}/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
        };
      };
    };

    home-manager.users.${user} = {
      services.ssh-agent.enable = true;
    };

  };
}
