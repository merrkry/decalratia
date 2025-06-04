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
      # imported by stylix
      # https://github.com/tinted-theming/tinted-tmux
      home.sessionVariables = {
        TINTED_TMUX_OPTION_STATUSBAR = 1;
      };

      programs.tmux = {
        enable = true;
        baseIndex = 1;
        clock24 = true;
        escapeTime = 10;
        keyMode = "vi";
        mouse = true;
        terminal = "tmux-256color";
        # about -g/-s, see https://github.com/tmux/tmux/wiki/Getting-Started#changing-options
        extraConfig = ''
          set -g renumber-windows on
          set -g set-clipboard on
          set -ga terminal-overrides ",xterm-256color:Tc,foot:Tc,xterm-kitty:Tc"
        '';
      };

      stylix.targets.tmux.enable = true;
    };
  };
}
