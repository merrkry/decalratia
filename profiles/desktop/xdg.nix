{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop.xdg;
in
{
  options.profiles.desktop.xdg = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };
  };
}
