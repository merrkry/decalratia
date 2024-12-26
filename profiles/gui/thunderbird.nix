{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.thunderbird;
in
{
  options.profiles.gui.thunderbird = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.thunderbird = {
        enable = true;
        profiles = { };
      };

    };

  };
}
