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
      fastfetch

      tree
      gdu
      just
      yq
      jq
      rclone
      dos2unix
      tlrc
      ripgrep
      fd
      _7zz

      gcc
      python3
      nodejs

      age
      sops

      neovim
    ];

    profiles = {
      cli = {
        git.enable = true;
        starship.enable = true;
        trash-cli.enable = true;
      };
      tui = {
        tmux.enable = true;
        yazi.enable = true;
      };
    };

    home-manager.users.${user} = {

      programs = {
        atuin.enable = true;
        btop.enable = true;
        zoxide.enable = true;
        fzf.enable = true;
      };

    };

  };
}
