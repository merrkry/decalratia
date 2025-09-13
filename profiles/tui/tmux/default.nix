{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.tmux;
in
{
  options.profiles.tui.tmux = {
    enable = lib.mkEnableOption "tmux";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.tmux = {
        enable = true;
        plugins = with pkgs.tmuxPlugins; [ vim-tmux-navigator ];

        # programs.tmux explicitly set these option by default
        aggressiveResize = true;
        baseIndex = 1;
        clock24 = true;
        focusEvents = true;
        historyLimit = 16384;
        keyMode = "vi";
        mouse = true;
        terminal = "tmux-256color";

        extraConfig = ''
          source-file ${./tmux.conf}
        '';
      };

      stylix.targets.tmux.enable = true;
    };
  };
}
