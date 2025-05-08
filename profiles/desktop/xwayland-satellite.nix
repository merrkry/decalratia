{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.xwayland-satellite;
in
{
  options.profiles.desktop.xwayland-satellite = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.niri.enable; };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home = {
        packages = with pkgs; [ xorg.xrandr ]; # some apps will crash without this
        # For some reason doesn't work, might be reset by niri
        # sessionVariables = {
        #   DISPLAY = ":42";
        # };
      };

      systemd.user = {
        services = {
          "xwayland-satellite" = {
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
        };
      };
    };
  };
}
