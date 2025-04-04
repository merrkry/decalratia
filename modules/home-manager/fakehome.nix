{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.fakehome;
in
{
  options.programs.fakehome = {
    enable = lib.mkEnableOption "fakehome wrapper" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.singleton (
      pkgs.writeShellScriptBin "fakeHome" ''
        ERR_RUN_UNDER_SUDO=1
        ERR_ARG_MISSING=2

        if [ -n "$SUDO_USER" ]; then
          echo 'Error: cannot run under sudo'
          exit $ERR_RUN_UNDER_SUDO
        fi

        app_name="$1"
        shift
        if [ -z "$app_name" ]; then
            echo 'Error: need at least one argument'
            exit $ERR_ARG_MISSING
        fi

        xdg_data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
        fake_home="$xdg_data_home/fakehome/$app_name"
        export HOME="$fake_home"

        mkdir -p "$HOME"
        exec "$app_name" "$@"
      ''
    );
  };
}
