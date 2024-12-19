{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base.xdg;
in
{
  options.profiles.base.xdg = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
  };

  config = lib.mkIf cfg.enable {

    programs.npm = lib.mkIf config.npm.enable {
      npmrc = ''
        prefix=''${XDG_DATA_HOME}/npm
        cache=''${XDG_CACHE_HOME}/npm
        init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
        tmp=''${XDG_RUNTIME_DIR}/npm
      '';
    };

    home-manager.users.${user} =
      let
        hmConfig = config.home-manager.users.${user};
      in
      {

        home = {
          sessionVariables = {
            XDG_DATA_HOME = hmConfig.xdg.dataHome;
            XDG_CONFIG_HOME = hmConfig.xdg.configHome;
            XDG_STATE_HOME = hmConfig.xdg.stateHome;
            XDG_CACHE_HOME = hmConfig.xdg.cacheHome;

            # data
            CARGO_HOME = "${hmConfig.xdg.dataHome}/cargo";
            GRADLE_USER_HOME = "${hmConfig.xdg.dataHome}/gradle";

            # config

            # state

            # cache
            CUDA_CACHE_PATH = "${hmConfig.xdg.cacheHome}/nv";

            # disable
            PYTHONSTARTUP =
              (pkgs.writeText "start.py" ''
                import readline
                readline.write_history_file = lambda *args: None
              '').outPath;
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

      };

  };
}
