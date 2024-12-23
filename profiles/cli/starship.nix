{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.cli.starship;
in
{
  options.profiles.cli.starship = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.starship = {
        enable = true;
        settings = {
          add_newline = false;
        };
        enableBashIntegration = false;

        settings = {
          nix_shell = {
            heuristic = true;
          };
        };
      };

    };

  };

}
