{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.presets.base;
in
{
  options.presets.base = {
    enable = lib.mkEnableOption "base" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    home.stateVersion = osConfig.system.stateVersion;
    systemd.user.startServices = "sd-switch";

    home.sessionVariables = {
      XDG_DATA_HOME = config.xdg.dataHome;
      XDG_CONFIG_HOME = config.xdg.configHome;
      XDG_STATE_HOME = config.xdg.stateHome;
      XDG_CACHE_HOME = config.xdg.cacheHome;

      CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";

      CARGO_HOME = "${config.xdg.dataHome}/cargo";

      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    };

    home.shellAliases = {
      "wget" = "wget --hsts-file=\"${config.xdg.dataHome}/wget-hsts\"";
      "rm" = "rm -i";
    };

    programs.bash = {
      enable = true;
      historyFile = "${config.xdg.stateHome}/bash/history";
    };

  };
}
