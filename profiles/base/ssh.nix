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
