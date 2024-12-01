{
  config,
  lib,
  pkgs,
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

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
      '';
    };

    programs.yazi.enable = true;

    environment.systemPackages = with pkgs; [
      fastfetch

      vim
      micro
      nano

      wget
      curl

      tree

      git
      lazygit

      gdu

      just

      yq
      jq

      nixd
      nixfmt-rfc-style

      rsync
      rclone

      lm_sensors

      # npm will NOT install this
      nodejs

      python3
      gcc

      ripgrep
    ];
  };
}
