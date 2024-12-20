{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.swaybg;
in
{
  options.programs.swaybg = {
    enable = lib.mkEnableOption "swaybg";
    image = lib.mkOption {
      type = lib.types.path;
      default = null;
      description = "Path to the background image";
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.user.services."swaybg" = {
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Unit = {
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.swaybg} -i ${cfg.image} -m fill";
        Restart = "on-failure";
      };
    };

  };
}
