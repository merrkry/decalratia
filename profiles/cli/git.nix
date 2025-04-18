{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.cli.git;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.cli.git = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    profiles.tui.lazygit.enable = true;

    home-manager.users.${user} = {
      programs.git = {
        enable = true;

        userName = "merrkry";
        userEmail = "merrkry@tsubasa.moe";
        ignores = [ ".direnv" ];

        extraConfig = {
          commit.gpgsign = true;
          credential.helper = "cache";
          gpg.format = "ssh";
          init.defaultBranch = "master";
          pull.rebase = true;
          safe.directory = "*";
          tag.gpgSign = true;
          user.signingkey = "${hmConfig.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
      };
    };
  };
}
