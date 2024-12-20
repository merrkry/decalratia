{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.chromium;
in
{
  options.profiles.gui.chromium = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [
        (ungoogled-chromium.override {
          commandLineArgs = lib.ChromiumArgs;
          enableWideVine = true;
        })
      ];

    };

  };
}
