{
  config,
  lib,
  pkgs,
  user,
  helpers,
  ...
}:
let
  cfg = config.profiles.desktop;
  hmConfig = config.home-manager.users.${user};
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.desktop = {
    enable = lib.mkEnableOption "desktop profile";
    enable32Bit = lib.mkEnableOption "enable 32-bit support" // {
      default = config.programs.steam.enable;
    };
    defaultTerminal = lib.mkOption {
      type = lib.types.enum [
        "foot"
        "kitty"
      ];
      default = "kitty";
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

    nix.daemonCPUSchedPolicy = "idle";

    profiles.gui = {
      ${cfg.defaultTerminal}.enable = true;

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
          ++ (with pkgs; [
            webkitgtk_4_1
            webkitgtk_6_0
          ]);
      };
      seahorse.enable = true;
    };

    services = {
      envfs.enable = true;
      speechd.enable = false; # never used, introduces huge dependencies
      xserver.excludePackages = with pkgs; [ xterm ];
    };

    home-manager.users.${user} = {
      # executes the same binary as nixos module, might be conflicting
      # services.gnome-keyring.enable = lib.mkDefault config.services.gnome.gnome-keyring.enable;

      systemd.user.tmpfiles.rules = [
        "d ${hmConfig.xdg.userDirs.download} - - - 14d -"
        # home-manager often blocked by backups created by its own
        "r ${hmConfig.xdg.configHome}/mimeapps.list.backup - - - - -"
      ];
    };
  };
}
