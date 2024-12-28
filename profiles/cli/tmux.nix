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
        # about -g/-s, see https://github.com/tmux/tmux/wiki/Getting-Started#changing-options
        extraConfig = ''
          set -g escape-time 10
          set -g mouse on
          set -g renumber-windows on
        '';
      };

    };

  };
}
