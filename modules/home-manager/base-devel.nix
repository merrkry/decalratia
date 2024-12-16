{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.presets.base-devel;
in
{
  options.presets.base-devel = {
    enable = lib.mkEnableOption "base-devel" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    home.shellAliases = {
      "pb" = "curl -F \"c=@-\" \"http://fars.ee/\"";
    };

    programs.bash.initExtra = ''
      if [[ $(${lib.getExe' pkgs.procps "ps"} --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${lib.getExe' pkgs.fish "fish"} $LOGIN_OPTION
      fi
    '';
    programs.fish.enable = true;

    programs.atuin.enable = true;
    programs.btop.enable = true;
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      extraConfig = ''
        set -g mouse on
        set -g renumber-windows on
      '';
    };
    programs.zoxide.enable = true;
    programs.fzf.enable = true;
    programs.yazi = {
      enable = true;
      settings = {
        manager = {
          ratio = [
            0
            4
            6
          ];
        };
      };
    };

    programs.git = {
      enable = true;

      userName = "merrkry";
      userEmail = "merrkry@tsubasa.moe";

      extraConfig = {
        safe.directory = "*";
        pull.rebase = true;
        init.defaultBranch = "master";
        credential.helper = "cache";
      };
    };

    services.ssh-agent.enable = true;

    home.packages = with pkgs; [
      lazygit
      nixd
      nixfmt-rfc-style
    ];

  };

}
