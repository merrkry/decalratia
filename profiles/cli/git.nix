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
    enable = lib.mkEnableOption "git";
  };

  config = lib.mkIf cfg.enable {
    profiles.tui.lazygit.enable = true;

    home-manager.users.${user} = {
      programs.git = {
        enable = true;

        userName = "merrkry";
        userEmail = "merrkry@tsubasa.moe";
        ignores = [ ".direnv" ];

        lfs.enable = true;

        # https://blog.gitbutler.com/how-git-core-devs-configure-git/
        extraConfig = {
          branch.sort = "-committerdate";
          column.ui = "auto";
          commit.gpgsign = true;
          credential.helper = "cache";
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };
          gpg.format = "ssh";
          help.autocorrect = "prompt";
          init.defaultBranch = "master";
          pull.rebase = true;
          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };
          tag = {
            gpgSign = true;
            sort = "version:refname";
          };
          user.signingkey = "${hmConfig.home.homeDirectory}/.ssh/id_ed25519.pub";
        };
      };
    };
  };
}
