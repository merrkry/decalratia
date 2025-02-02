{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.tmux-sessionizer;
  tmux-sessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
    if [[ $# -eq 1 ]]; then
        selected=$1
    else
        selected=$(${lib.getExe' pkgs.findutils "find"} ~/Projects -mindepth 1 -maxdepth 1 -type d | ${lib.getExe' pkgs.fzf "fzf"})
    fi

    if [[ -z $selected ]]; then
        exit 0
    fi

    selected_name=$(${lib.getExe' pkgs.coreutils-full "basename"} "$selected" | ${lib.getExe' pkgs.coreutils-full "tr"} . _)
    tmux_running=$(${lib.getExe' pkgs.procps "pgrep"} tmux)

    if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
        ${lib.getExe pkgs.tmux} new-session -s $selected_name -c $selected
        exit 0
    fi

    if ! ${lib.getExe pkgs.tmux} has-session -t=$selected_name 2> /dev/null; then
        ${lib.getExe pkgs.tmux} new-session -ds $selected_name -c $selected
    fi

    if [[ -z $TMUX ]]; then
        ${lib.getExe pkgs.tmux} attach -t $selected_name
    else
        ${lib.getExe pkgs.tmux} switch-client -t $selected_name
    fi
  '';
in
{
  options.programs.tmux-sessionizer = {
    enable = lib.mkEnableOption "tmux-sessionizer";
    # TODO: add options to diffrent shell integrations
    # TODO: add option to specify projects folder
  };

  config = lib.mkIf cfg.enable {

    home.packages = [ tmux-sessionizer ];

    programs = {
      fish.interactiveShellInit = ''
        bind \cf ${lib.getExe tmux-sessionizer}
      '';

      tmux.extraConfig = ''
        bind j new-window ${lib.getExe tmux-sessionizer}
      '';
    };

  };
}
