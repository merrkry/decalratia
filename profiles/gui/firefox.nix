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

    programs.firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "zh-CN"
      ];
    };

    home-manager.users.${user} = {

      # gtk styling will however still be applied to firefox
      stylix.targets.firefox.enable = false;

    };

  };
}
