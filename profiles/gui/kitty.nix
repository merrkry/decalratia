{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.kitty;
in
{
  options.profiles.gui.kitty = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.kitty = {
        enable = true;
        settings = {
          enable_audio_bell = "no";
        };
      };

      stylix.targets.kitty.enable = true;
    };
  };
}
