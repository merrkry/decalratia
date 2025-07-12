{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.cli.eza;
in
{
  options.profiles.cli.eza = {
    enable = lib.mkEnableOption "eza";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.eza = {
        enable = true;

        # replace `ls` `la` etc. via aliases
        enableBashIntegration = false;
        enableFishIntegration = true;
      };
    };
  };
}
