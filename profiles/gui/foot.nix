{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.foot;
in
{
  options.profiles.gui.foot = {
    enable = lib.mkEnableOption "foot";
  };

  config = lib.mkIf cfg.enable {
    programs.foot.enable = true;

    home-manager.users.${user} = {
      programs.foot = {
        enable = true;
        # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
        settings =
          let
            mapleMono = "Maple Mono CN:size=${toString config.stylix.fonts.sizes.terminal}";
          in
          {
            main = {
              font-italic = mapleMono;
              font-bold-italic = mapleMono;
            };
            cursor = {
              style = "beam";
            };
            environment = {
              LANG = "en_US.UTF-8";
            };
            key-bindings = {
              primary-paste = "none";
              search-start = "none";
              spawn-terminal = "none";
              pipe-visible = "none";
              pipe-scrollback = "none";
              pipe-selected = "none";
              pipe-command-output = "none";
              # show-urls-launch = "none"; # <C-S-o>
              prompt-prev = "none";
              prompt-next = "none";
              unicode-input = "none";
            };
          };
      };

      stylix.targets.foot.enable = true;
    };
  };
}
