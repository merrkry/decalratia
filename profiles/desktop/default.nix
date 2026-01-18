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
  aioShell = config.profiles.desktop.noctalia.enable;

  compositorProfiles = {
    niri = {
      screenOffCmd = "${lib.getExe' cfg.niri.package "niri"} msg action power-off-monitors";
      sessionCmd = lib.getExe' cfg.niri.package "niri-session";
    };
  };
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.desktop = with lib; {
    enable = mkEnableOption "desktop profile";

    enable32Bit = mkEnableOption "enable 32-bit support" // {
      default = config.programs.steam.enable;
    };

    defaultTerminal = mkOption {
      type = types.enum [
        "foot"
        "kitty"
      ];
      default = "foot";
    };

    compositor = mkOption {
      type = types.enum [
        "niri"
      ];
      default = "niri";
    };

    compositorProfile = mkOption {
      type = types.submodule {
        options = {
          screenOffCmd = mkOption { type = types.str; };
          sessionCmd = mkOption { type = types.str; };
        };
      };
      default = compositorProfiles.${cfg.compositor};
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      # `q /srv 0755 - - -` removed to prevent /srv created as subvol
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
      inherit (cfg) enable32Bit;
    };

    nix.daemonCPUSchedPolicy = "idle";

    profiles = {
      desktop = {
        audio.enable = true;
        bluetooth.enable = true;
        flatpak.enable = true;
        i18n.enable = true;
        input.enable = true;
        lock.enable = true;
        login.enable = true;
        mime.enable = true;
        network.enable = true;
        plymouth.enable = true;
        security.enable = true;
        themes.enable = true;
        tweaks.enable = true;
        watchdog.enable = true;
        waybar.enable = lib.mkDefault (!aioShell);
        xdg.enable = true;
      };
      gui = {
        ${cfg.defaultTerminal}.enable = true;

        chromium.enable = true;
        firefox.enable = true;
        localsend.enable = true;
        mpv.enable = true;
        rofi.enable = lib.mkDefault (!aioShell);
        swaync.enable = lib.mkDefault (!aioShell);
      };
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
      home.packages = with pkgs; [
        # brightness
        brightnessctl

        # clipboard
        wl-clipboard
        cliphist

        # compression
        _7zz-rar
        (ouch.override { enableUnfree = true; })
        unzipNLS
      ];

      systemd.user.tmpfiles.rules = [
        "d ${hmConfig.xdg.userDirs.download} - - - 14d -"
        # home-manager often blocked by backups created by its own
        "r ${hmConfig.xdg.configHome}/mimeapps.list.backup - - - - -"
      ];

    };
  };
}
