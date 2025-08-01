{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.helix;
in
{
  options.profiles.tui.helix = {
    enable = lib.mkEnableOption "helix";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.helix = {
        enable = true;
        defaultEditor = false;
      };
    };
  };
}
