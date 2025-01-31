{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.tmux;
in
{
  options.profiles.tui.tmux = {
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
          set -g set-clipboard on
          set -g default-terminal "tmux-256color"
          set-option -as terminal-overrides ",foot:Tc"
        '';
      };

    };

  };
}
