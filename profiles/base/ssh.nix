{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base.ssh;
  askPasswordWrapper = pkgs.writeScript "ssh-askpass-wrapper" ''
    #! ${pkgs.runtimeShell} -e
    eval export $(systemctl --user show-environment | ${lib.getExe pkgs.gnugrep} -E '^(DISPLAY|WAYLAND_DISPLAY|XAUTHORITY)=')
    exec ${pkgs.seahorse}/libexec/seahorse/ssh-askpass "$@"
  '';
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
      fail2ban = {
        enable = true;
        ignoreIP = [
          "100.64.0.0/10" # CGNAT, used by tailscale
        ];
      };
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
      # services.ssh-agent.enable = true; # doesn't support manually set extra arguments
      home = {
        packages = [ pkgs.sshs ];
        sessionVariables = {
          SSH_ASKPASS = askPasswordWrapper;
        };
        sessionVariablesExtra = ''
          if [ -z "$SSH_AUTH_SOCK" ]; then
            export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
          fi
        '';
      };
      systemd.user.services.ssh-agent = {
        Install.WantedBy = [ "default.target" ];

        Unit = {
          Description = "SSH authentication agent";
          Documentation = "man:ssh-agent(1)";
        };

        Service = {
          Environment = [
            "DISPLAY=fake"
            "SSH_ASKPASS=${askPasswordWrapper}"
          ];
          ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent -t 3600";
        };
      };
    };
  };
}
