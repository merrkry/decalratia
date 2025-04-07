{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.btop;
in
{
  options.profiles.tui.btop = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.btop ];

    home-manager.users.${user} = {
      programs.btop.enable = true;
      stylix.targets.btop.enable = true;
    };
  };
}
