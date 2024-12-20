{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.swaync;
in
{
  options.profiles.gui.swaync = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      services.swaync = {
        enable = true;
        # https://man.archlinux.org/man/swaync.5.en
        settings = {
          timeout = 5;
          timeout-low = 5;
          timeout-critical = 5;
        };
      };

    };

  };
}
