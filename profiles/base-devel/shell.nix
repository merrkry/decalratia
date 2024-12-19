{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base-devel.shell;
in
{
  options.profiles.base-devel.shell = {
    enable = lib.mkEnableOption' { default = config.profiles.base-devel.enable; };
  };

  config = lib.mkIf cfg.enable {

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
      '';
    };

    home-manager.users.${user} = {

      home.shellAliases = {

      };

      programs = {
        bash.initExtra = ''
          if [[ $(${lib.getExe' pkgs.procps "ps"} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${lib.getExe' pkgs.fish "fish"} $LOGIN_OPTION
          fi
        '';
        fish.enable = true;
      };

    };

  };
}
