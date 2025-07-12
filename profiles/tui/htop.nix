{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.htop;
in
{
  options.profiles.tui.htop = {
    enable = lib.mkEnableOption "htop";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.htop ];

    home-manager.users.${user} = {
      programs.htop = {
        enable = true;
      };
    };
  };
}
