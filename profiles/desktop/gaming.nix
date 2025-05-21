{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.gaming;
in
{
  options.profiles.desktop.gaming = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    programs.gamescope.enable = true;

    home-manager.users.${user} = {
      home.packages = with pkgs; [ joystickwake ];
    };
  };
}
