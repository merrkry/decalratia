{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.zed;
in
{
  options.profiles.gui.zed = {
    enable = lib.mkEnableOption' { };
    enableAI = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.zed-editor.enable = true;

      # stylix.targets.zed.enable = true;
    };
  };
}
