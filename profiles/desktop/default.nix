{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.desktop = {
    enable = lib.mkEnableOption "desktop profile";
    enable32Bit = lib.mkEnableOption "enable 32-bit support" // {
      default = config.programs.steam.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    environment = {
      # `q /srv 0755 - - -` removed to prevent /srv becreated as subvol
      etc."tmpfiles.d/home.conf".text = ''
        Q /home 0755 - - -
      '';

      # required by home-manager xdg.portal.enable
      pathsToLink = [
        "/share/xdg-desktop-portal"
        "/share/applications"
      ];
    };

    hardware.graphics = {
      enable = true;
      enable32Bit = cfg.enable32Bit;
    };

    programs.appimage = {
      enable = true;
      binfmt = true;
    };

    services = {
      flatpak.enable = true;

      xserver.excludePackages = with pkgs; [ xterm ];
    };

    home-manager.users.${user} = {

      home.sessionVariables = {
        # Workaround for https://bugs.kde.org/show_bug.cgi?id=479891
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
      };

      services.gnome-keyring.enable = lib.mkDefault config.services.gnome.gnome-keyring.enable;

    };

  };
}
