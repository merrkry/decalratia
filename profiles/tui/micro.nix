{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.micro;
in
{
  options.profiles.tui.micro = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.micro ];

    home-manager.users.${user} = {
      programs.micro.enable = true;
      stylix.targets.micro.enable = true;
    };
  };
}
