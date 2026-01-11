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
          src = pkgs.fetchFromGitHub {
            owner = "acomagu";
            repo = "fish-async-prompt";
            rev = "8a7f2b19fffd64667db84b4aca6221b33f044fce";
            hash = "sha256-99eGL8o4yCE5zDJD5fRDhf6Va1Q6GMhsD+v5Jn3iJoc=";
          };
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
