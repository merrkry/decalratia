{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.zellij;
in
{
  options.profiles.tui.zellij = {
    enable = lib.mkEnableOption "zellij";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.zellij = {
        enable = true;
      };

      stylix.targets.zellij.enable = true;
    };
  };
}
