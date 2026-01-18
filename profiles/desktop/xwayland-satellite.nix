{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.xwayland-satellite;
  systemdService = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Before = [ "fcitx5.service" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.xwayland-satellite} :42";
      Restart = "on-failure";
      StandardOutput = "null";
    };
  };
in
{
  options.profiles.desktop.xwayland-satellite = {
    enable = lib.mkEnableOption "xwayland-satellite";
    package = lib.mkPackageOption pkgs "xwayland-satellite" { };
    enableService = lib.mkEnableOption "systemd service";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.users.${user} = {
          home.packages = with pkgs; [ xorg.xrandr ]; # some apps will crash without this
        };
      }

      (lib.mkIf cfg.enableService {
        home-manager.users.${user} = {
          systemd.user.services."xwayland-satellite" = systemdService;
        };
      })
    ]
  );
}
