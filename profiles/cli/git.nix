{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.git;
in
{
  options.profiles.cli.git = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [ lazygit ];

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

    };

  };
}
