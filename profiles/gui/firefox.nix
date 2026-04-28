{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.firefox;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.gui.firefox = {
    enable = lib.mkEnableOption "firefox";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.firefox = {
        enable = true;
        package = pkgs.firefox-beta;
        configPath = "${hmConfig.xdg.configHome}/mozilla/firefox";
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
