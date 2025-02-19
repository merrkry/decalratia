{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop;
  hmConfig = config.home-manager.users.${user};
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

    profiles.gui = {
      chromium.enable = true;
      firefox.enable = true;
      localsend.enable = true;
      mpv.enable = true;
      rofi.enable = true;
      swaync.enable = true;
    };

    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      dconf.enable = true;
      nix-ld = {
        enable = true;
        libraries =
          (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs pkgs)
          ++ (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs)
          ++ (with pkgs; [ webkitgtk_6_0 ]);
      };
      seahorse.enable = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;
      xserver.excludePackages = with pkgs; [ xterm ];
    };

    home-manager.users.${user} = {
      programs = {
        foot.enable = true;
      };

      services.gnome-keyring.enable = lib.mkDefault config.services.gnome.gnome-keyring.enable;

      systemd.user.tmpfiles.rules = [ "D ${hmConfig.xdg.userDirs.download} - - - 14d -" ];
    };
  };
}
