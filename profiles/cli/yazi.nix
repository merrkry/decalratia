{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.cli.yazi;
in
{
  options.profiles.cli.yazi = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.yazi = {
        enable = true;
        settings = {
          manager = {
            ratio = [
              0
              4
              6
            ];
          };
        };
      };

    };

  };
}
