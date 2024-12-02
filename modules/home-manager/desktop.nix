{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.presets.desktop;
in
{
  imports = [ ./fakehome.nix ];

  options.presets.desktop = {
    enable = lib.mkEnableOption "desktop" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    home.sessionVariables = {
      # Workaround for https://bugs.kde.org/show_bug.cgi?id=479891
      QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
    };

    # TODO: generate this symlink via script
    # .local/share/fonts/system -> /run/current-system/sw/share/X11/fonts

    services.gnome-keyring.enable = lib.mkDefault osConfig.services.gnome.gnome-keyring.enable;

    home.packages = with pkgs; [
      trash-cli

      xorg.xeyes
      glxinfo
      vulkan-tools
    ];
  };
}
