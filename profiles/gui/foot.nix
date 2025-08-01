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
        server.enable = true;
        # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
        settings = {
          key-bindings = {
            primary-paste = "none";
            search-start = "none";
            spawn-terminal = "none";
            pipe-visible = "none";
            pipe-scrollback = "none";
            pipe-selected = "none";
            pipe-command-output = "none";
            show-urls-launch = "none";
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
