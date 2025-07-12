{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.librewolf;
in
{
  options.profiles.gui.librewolf = {
    enable = lib.mkEnableOption "librewolf";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.librewolf = {
        enable = true;
        languagePacks = [
          "en-US"
          "zh-CN"
        ];
      };
    };
  };
}
