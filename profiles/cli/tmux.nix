{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.cli.tmux;
in
{
  options.profiles.cli.tmux = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.tmux = {
        enable = true;
        baseIndex = 1;
        extraConfig = ''
          set -g mouse on
          set -g renumber-windows on
        '';
      };

    };

  };
}
