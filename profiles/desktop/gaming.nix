{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.gaming;
in
{
  options.profiles.desktop.gaming = {
    enable = lib.mkEnableOption "gaming";
    enableNTSync = lib.mkEnableOption "NTSync" // {
      default = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.14";
    };
    steam = {
      enable = lib.mkEnableOption "Steam" // {
        default = true;
      };
      bwrapHome = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.gamescope.enable = true;

        home-manager.users.${user} = {
          home.packages = with pkgs; [
            joystickwake # relies on xdg autostart, maybe better to migrate to systemd
          ];
        };
      }
      (lib.mkIf cfg.enableNTSync {
        boot.kernelModules = [ "ntsync" ];

        services.udev.packages = [
          (pkgs.writeTextFile {
            name = "ntsync-udev-rules";
            text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
            destination = "/etc/udev/rules.d/70-ntsync.rules";
          })
        ];
      })
      (lib.mkIf cfg.steam.enable {
        programs.steam = {
          enable = true;

          package = pkgs.steam.override {
            # https://github.com/YaLTeR/niri/wiki/Application-Issues#steam
            extraArgs = "-system-composer";
            # Utilize bwrap to prevent steam dump garbage everywhere in HOME.
            # https://github.com/ValveSoftware/steam-for-linux/issues/1890#issuecomment-2367103614
            extraBwrapArgs =
              if cfg.steam.bwrapHome != null then
                [
                  "--bind ${cfg.steam.bwrapHome} $HOME"
                  "--unsetenv XDG_CACHE_HOME"
                  "--unsetenv XDG_CONFIG_HOME"
                  "--unsetenv XDG_DATA_HOME"
                  "--unsetenv XDG_STATE_HOME"
                  "--setenv GTK_IM_MODULE xim"
                ]
              else
                [ ];
          };

          extraCompatPackages = [ pkgs.proton-ge-bin ];

          # https://help.steampowered.com/en/faqs/view/2EA8-4D75-DA21-31EB
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          remotePlay.openFirewall = true;

          extest.enable = true;
        };

        home-manager.users.${user} = {
          # We need a version without hidden home directory to run non-steam games
          home.packages = [ pkgs.steam-run ];

          systemd.user.tmpfiles.rules = lib.mkIf (cfg.steam.bwrapHome != null) [
            "d ${cfg.steam.bwrapHome} - - - - -"
          ];
        };
      })
    ]
  );
}
