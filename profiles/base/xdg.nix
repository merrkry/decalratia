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

  runtimeDir = "/run/user/${toString config.users.users.${user}.uid}";
  inherit (hmConfig.xdg)
    binHome
    cacheHome
    configHome
    dataHome
    stateHome
    ;
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

        shellAliases = {
          "adb" = "HOME=\"${dataHome}/android\" adb";
          "rm" = "rm -i";
          "wget" = "wget --hsts-file=\"${dataHome}/wget-hsts\"";
        };
      };

      programs.bash = {
        enable = true;
        historyFile = "${stateHome}/bash/history";
      };

      systemd.user = {
        # Use systemd to make sure these applies to graphical applications as well.
        sessionVariables = {
          # android
          ANDROID_USER_HOME = "${dataHome}/android";

          # codex
          CODEX_HOME = "${dataHome}/codex";

          # cuda
          CUDA_CACHE_PATH = "${cacheHome}/nv";

          # dotnet
          DOTNET_CLI_HOME = "${dataHome}/dotnet";

          # java
          GRADLE_USER_HOME = "${dataHome}/gradle";

          # npm
          NPM_CONFIG_INIT_MODULE = "${dataHome}/npm/config/npm-init.js";
          NPM_CONFIG_CACHE = "${cacheHome}/npm";
          NPM_CONFIG_TMP = "${runtimeDir}/npm";

          # python
          # <= 3.12
          PYTHONSTARTUP =
            (pkgs.writeText "start.py" ''
              import readline
              readline.write_history_file = lambda *args: None
            '').outPath;
          # >= 3.13
          PYTHON_HISTORY = "/dev/null";

          # rust
          CARGO_HOME = "${dataHome}/cargo";
          RUSTUP_HOME = "${dataHome}/rustup";

          # wine
          WINEPREFIX = "${dataHome}/win";
        };

        tmpfiles.rules = [
          "d ${binHome} 700"
          "d ${cacheHome} 700"
          "d ${configHome} 700"
          "d ${dataHome} 700"
          "d ${stateHome} 700"

          "f ${stateHome}/bash/history" # xdg-ninja suggests manual creation.
        ];
      };

      xdg = {
        enable = true;

        # messy behavior
        autostart.enable = lib.mkForce false;

        configFile = {
          "go/env".text = ''
            GOPATH=${cacheHome}/go
            GOBIN=${stateHome}/go/bin
          '';
        };
      };
    };
  };
}
