{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.pure;
in
{
  options.profiles.cli.pure = {
    enable = lib.mkEnableOption "pure";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.fish.plugins = [
        {
          name = "pure";
          inherit (pkgs.fishPlugins.pure) src;
        }
        {
          name = "async-prompt";
          inherit (pkgs.fishPlugins.async-prompt) src;
        }
      ];

      xdg.configFile."fish/conf.d/plugin-pure-config.fish".text =
        # fish
        ''
          set --universal pure_enable_nixdevshell true
          set --universal async_prompt_functions _pure_prompt_git
        '';
    };
  };
}
