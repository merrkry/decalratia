{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base.xdg;
  hmConfig = config.home-manager.users.${user};
  # might need a better way to ref XDG_RUNTIME_DIR
  runtimeDir = "/run/user/${toString config.users.users.${user}.uid}";
in
{
  options.profiles.base.xdg = {
    enable = lib.mkEnableOption "xdg" // {
      default = config.profiles.base.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home = {
        packages = with pkgs; [ xdg-utils ];

        # Reverse to make priority more intuitive
        # Now they are overriden in the sequence here
        sessionPath = lib.lists.reverseList [
          "$HOME/.local/bin"
          "${hmConfig.xdg.stateHome}/go/bin"
        ];

        sessionVariables = {
          XDG_DATA_HOME = hmConfig.xdg.dataHome;
          XDG_CONFIG_HOME = hmConfig.xdg.configHome;
          XDG_STATE_HOME = hmConfig.xdg.stateHome;
          XDG_CACHE_HOME = hmConfig.xdg.cacheHome;

          # data
          CARGO_HOME = "${hmConfig.xdg.dataHome}/cargo";
          GRADLE_USER_HOME = "${hmConfig.xdg.dataHome}/gradle";

          # config
          NPM_CONFIG_INIT_MODULE = "${hmConfig.xdg.configHome}/npm/config/npm-init.js";

          # state

          # cache
          CUDA_CACHE_PATH = "${hmConfig.xdg.cacheHome}/nv";
          NPM_CONFIG_CACHE = "${hmConfig.xdg.cacheHome}/npm";

          # runtime
          NPM_CONFIG_TMP = "${runtimeDir}/npm";

          # disable
          # up to 3.12
          PYTHONSTARTUP =
            (pkgs.writeText "start.py" ''
              import readline
              readline.write_history_file = lambda *args: None
            '').outPath;
          # 3.13+
          PYTHON_HISTORY = "/dev/null";
        };

        shellAliases = {
          "rm" = "rm -i";
          "wget" = "wget --hsts-file=\"${hmConfig.xdg.dataHome}/wget-hsts\"";
        };
      };

      programs.bash = {
        enable = true;
        historyFile = "${hmConfig.xdg.stateHome}/bash/history";
      };

      xdg = {
        enable = true;

        # messy behavior
        autostart.enable = lib.mkForce false;

        configFile = {
          "go/env".text = ''
            GOPATH=${hmConfig.xdg.cacheHome}/go
            GOBIN=${hmConfig.xdg.stateHome}/go/bin
          '';
        };
      };
    };
  };
}
