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
          src = pkgs.fishPlugins.pure.src;
        }
        {
          name = "async-prompt";
          src = pkgs.fetchFromGitHub {
            owner = "acomagu";
            repo = "fish-async-prompt";
            rev = "316aa03c875b58e7c7f7d3bc9a78175aa47dbaa8";
            hash = "sha256-J7y3BjqwuEH4zDQe4cWylLn+Vn2Q5pv0XwOSPwhw/Z0=";
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
