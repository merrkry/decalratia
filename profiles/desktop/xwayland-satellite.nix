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
        # Will be reset by niri. Set this in niri's config instead.
        # https://github.com/YaLTeR/niri/blob/7a10f71ee564a7c1054683929f6a0110b0fa3b56/src/main.rs#L75-L78
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
