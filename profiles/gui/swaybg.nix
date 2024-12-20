{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.swaybg;
in
{
  options.profiles.gui.swaybg = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} =
      let
        hmConfig = config.home-manager.users.${user};
      in
      {

        systemd.user.services."swaybg" = {
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Unit = {
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${lib.getExe pkgs.swaybg} -i ${hmConfig.stylix.image} -m fill";
            Restart = "on-failure";
          };
        };

      };

  };
}
