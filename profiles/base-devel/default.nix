{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.base-devel;
in
{
  imports = lib.mkModulesList ./.;

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
      tlrc
      tree
      yq
    ];

    profiles = {
      cli = {
        bat.enable = true;
        tide.enable = true;
        git.enable = true;
        trash-cli.enable = true;
      };

      tui = {
        atuin.enable = true;
        btop.enable = true;
        fzf.enable = true;
        tmux.enable = true;
        yazi.enable = true;
      };
    };

    programs = {
      mtr.enable = true;
      nexttrace.enable = true;
    };

    home-manager.users.${user} = {
      programs = {
        tmux-sessionizer.enable = true;
        zoxide.enable = true;
      };
    };
  };
}
