{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.cli.trash-cli;
in
{
  options.profiles.cli.trash-cli = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [ trash-cli ];

    systemd = {
      timers."trash-cli-cleanup" = {
        wantedBy = [ "default.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      services."trash-cli-cleanup" = {
        enableStrictShellChecks = true;
        script = ''
          ${lib.getExe' pkgs.trash-cli "trash-empty"} 30 --all-users -f
        '';
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };

  };
}
