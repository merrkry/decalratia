{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.firefox;
in
{
  options.profiles.gui.firefox = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.firefox = {
        enable = true;
        languagePacks = [
          "en-US"
          "zh-CN"
        ];
      };

      # gtk styling will however still be applied to firefox
      stylix.targets.firefox.enable = false;

    };

  };
}
