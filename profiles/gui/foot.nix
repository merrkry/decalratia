{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.foot;
in
{
  options.profiles.gui.foot = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    programs.foot.enable = true;

    home-manager.users.${user} = {
      programs.foot = {
        enable = true;
        server.enable = true;
      };

      stylix.targets.foot.enable = true;
    };
  };
}
