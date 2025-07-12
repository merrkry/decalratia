{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.fzf;
in
{
  options.profiles.tui.fzf = {
    enable = lib.mkEnableOption "fzf";
  };

  config = lib.mkIf cfg.enable {

    programs.fzf = {
      fuzzyCompletion = true;
      keybindings = false;
    };

    home-manager.users.${user} = {
      programs.fzf.enable = true;
      stylix.targets.fzf.enable = true;
    };
  };
}
