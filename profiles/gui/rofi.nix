{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.rofi;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.gui.rofi = {
    enable = lib.mkEnableOption "rofi";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.rofi = {
        enable = true;
        terminal = config.profiles.desktop.defaultTerminal;
      };

      stylix.targets.rofi.enable = true;
    };
  };
}
