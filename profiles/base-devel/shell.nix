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

    stylix.targets.fish.enable = true;

    home-manager.users.${user} = {

      home = {
        packages = with pkgs; [
          foot.terminfo
          kitty.terminfo
        ];
        shellAliases = {
          "cdf" = "cd \"$(fd --max-depth 3 --type directory --hidden --exclude '.git' | fzf)\" 2> /dev/null";
          "gpp" = "g++ -x c++ -std=gnu++2b -Wall -Wextra";
        };
      };

      programs = {
        bash.initExtra = ''
          if [[ $(${lib.getExe' pkgs.procps "ps"} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${lib.getExe' pkgs.fish "fish"} $LOGIN_OPTION
          fi
        '';
        direnv = {
          enable = true;
          config = {
            global.hide_env_diff = true; # only hide unreadable part instead of completely disable logging
          };
          nix-direnv.enable = true;
        };
        fish.enable = true;
      };

    };

  };
}
