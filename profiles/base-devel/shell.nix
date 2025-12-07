{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base-devel.shell;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.base-devel.shell = {
    enable = lib.mkEnableOption "shell" // {
      default = config.profiles.base-devel.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      direnv = {
        enable = true;
        angrr = {
          enable = true;
          autoUse = true;
        };
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set -U fish_greeting
        '';
      };
    };

    stylix.targets.fish.enable = true;

    home-manager.users.${user} = {
      home = {
        sessionVariables = {
          # Overwrite nixos module's value to respect local config
          # https://github.com/NixOS/nixpkgs/blob/f61125a668a320878494449750330ca58b78c557/nixos/modules/programs/direnv.nix#L159
          DIRENV_CONFIG = "${hmConfig.xdg.configHome}/direnv";
        };
        shellAliases = {
          "cdf" = "cd \"$(fd --max-depth 3 --type directory --hidden --exclude '.git' | fzf)\" 2> /dev/null";
          "gpp" = "g++ -x c++ -std=gnu++2b -Wall -Wextra";
        };
      };

      programs = {
        bash.initExtra = lib.mkOrder 10000 ''
          if [[ $(${lib.getExe' pkgs.procps "ps"} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
          then
            shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
            exec ${lib.getExe' hmConfig.programs.fish.package "fish"} $LOGIN_OPTION
          fi
        '';

        direnv = {
          enable = true;
          config = {
            global.hide_env_diff = true; # only hide unreadable part instead of completely disable logging
          };
        };

        fish.enable = true;

        nix-your-shell.enable = true;
      };
    };
  };
}
