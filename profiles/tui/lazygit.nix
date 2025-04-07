{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.lazygit;
in
{
  options.profiles.tui.lazygit = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.lazygit.enable = true;
      stylix.targets.lazygit.enable = true;
    };
  };
}
