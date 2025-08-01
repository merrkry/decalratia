{
  config,
  lib,
  pkgs,
  user,
  helpers,
  ...
}:
let
  cfg = config.profiles.base-devel;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.base-devel = {
    enable = lib.mkEnableOption "base-devel profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      age
      fastfetch
      fd
      gcc
      gdu
      jq
      just
      neovim
      python3
      ripgrep
      rclone
      sops
      squashfsTools
      tlrc
      tree
      yq
    ];

    profiles = {
      cli = {
        bat.enable = true;
        eza.enable = true;
        git.enable = true;
        pure.enable = true;
        trash-cli.enable = true;
      };

      tui = {
        atuin.enable = true;
        btop.enable = true;
        fzf.enable = true;
        htop.enable = true;
        tmux.enable = true;
        tmux-sessionizer.enable = true;
        yazi.enable = true;
      };
    };

    programs = {
      mtr.enable = true;
      nexttrace.enable = true;
    };

    home-manager.users.${user} = {
      home.sessionVariables = {
        EDITOR = "nvim";
      };
      programs = {
        zoxide.enable = true;
      };
    };
  };
}
