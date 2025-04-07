{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.bat;
in
{
  options.profiles.cli.bat = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.bat ];

    home-manager.users.${user} = {
      programs.bat.enable = true;
      stylix.targets.bat.enable = true;
    };
  };
}
