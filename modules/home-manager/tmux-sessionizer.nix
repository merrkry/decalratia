{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux-sessionizer;
  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
    if [[ $# -ge 1 ]]; then
      selected="$1"
    else
      # use glob to filter out hidden directories, to avoid fd handling wildcards in .gitignore weiredly
      selected="$(fd --type directory --max-depth 2 --min-depth 1 --exclude '.*' . ~/Projects | fzf)"
    fi

    if [[ -z "$selected" ]]; then
      exit 0
    fi

    if [[ $# -eq 2 ]]; then
      selected_name="$2"
    else
      selected_name="$(basename "$(realpath "$selected")" | tr . _)"
    fi

    tmux_running=$(pgrep tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
      tmux new-session -s "$selected_name" -c "$selected"
      exit 0
    fi

    if ! tmux has-session -t="$selected_name" 2> /dev/null; then
      tmux new-session -ds "$selected_name" -c "$selected"
    fi

    if [[ -z $TMUX ]]; then
      tmux attach -t "$selected_name"
    else
      tmux switch-client -t "$selected_name"
    fi
  '';
in
{
  options.programs.tmux-sessionizer = {
    enable = lib.mkEnableOption "tmux-sessionizer";
    # TODO: add options to diffrent shell integrations
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.fd
      pkgs.fzf
      tmux-sessionizer
    ];

    programs = {
      fish.interactiveShellInit = ''
        bind \cf ${lib.getExe tmux-sessionizer}
      '';

      tmux = {
        enable = true;
        extraConfig = ''
          bind j new-window ${lib.getExe tmux-sessionizer}
        '';
      };
    };

  };
}
