{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.eog;
in
{
  options.profiles.gui.eog = {
    enable = lib.mkEnableOption "eog";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = [ pkgs.eog ];
      stylix.targets.eog.enable = true;
    };
  };
}
