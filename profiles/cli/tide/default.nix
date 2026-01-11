{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.tide;
in
{
  options.profiles.cli.tide = {
    enable = lib.mkEnableOption "tide";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.fish.plugins = [
        {
          name = "tide";
          inherit (pkgs.fishPlugins.tide) src;
        }
      ];

      # source: https://gist.github.com/wrvsrx/9ee788091200650c97ae3b055b08a4a2
      xdg.configFile."fish/conf.d/tide_config.fish".source = "${
        pkgs.callPackage ./tide-config.nix { }
      }/conf.d/_tide_config.fish";
    };
  };
}
