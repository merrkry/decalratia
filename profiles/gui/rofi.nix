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
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${lib.getExe hmConfig.programs.foot.package}";
      };

      stylix.targets.rofi.enable = true;
    };
  };
}
