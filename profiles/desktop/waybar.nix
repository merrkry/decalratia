{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.waybar;
in
{
  options.profiles.desktop.waybar = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    # TODO: accept a list of devices
    backlightDevice = lib.mkOption {
      type = lib.types.str;
      default = "intel_backlight";
      description = "The backlight device to control";
    };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} =
      let
        hmConfig = config.home-manager.users.${user};
      in
      {

        programs.waybar = {
          enable = true;
          systemd.enable = true;

          settings =
            let
              globalIconSize = 20;
              terminal = "${lib.getExe hmConfig.programs.foot.package}";
            in
            (lib.singleton {
              layer = "top";
              spacing = 8;
              modules-left = [ "niri/workspaces" ];
              modules-center = [ "clock" ];
              modules-right = [
                "systemd-failed-units"
                "tray"
                "privacy"
                # "mpris"
                "backlight"
                "wireplumber"
                "battery"
                "custom/notification"
              ];
              "backlight" = {
                device = cfg.backlightDevice;
                format = "{percent}%  {icon}";
                format-icons = [
                  ""
                  # ""
                ];
                # too sensitive :(
                on-scroll-up = "${lib.getExe pkgs.brightnessctl} set +1%";
                on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 1%-";
              };
              "battery" = {
                format = "{capacity}%  {icon}";
                format-icons = [
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
                on-click = "${terminal} ${lib.getExe hmConfig.programs.btop.package}";
              };
              "clock" = {
                tooltip = false;
              };
              # https://github.com/ErikReider/SwayNotificationCenter?tab=readme-ov-file#waybar-example
              "custom/notification" = {
                tooltip = false;
                format = "{icon}   "; # workaround, add padding on the right edge of the bar
                format-icons = {
                  notification = "󰂚<span foreground='red'><sup></sup></span>";
                  none = "󰂚";
                  dnd-notification = "󰂛<span foreground='red'><sup></sup></span>";
                  dnd-none = "󰂛";
                  inhibited-notification = "󰂚<span foreground='red'><sup></sup></span>";
                  inhibited-none = "󰂚";
                  dnd-inhibited-notification = "󰂛<span foreground='red'><sup></sup></span>";
                  dnd-inhibited-none = "󰂛";
                };
                return-type = "json";
                exec-if = "which swaync-client"; # TODO: check services.swaync.enable
                exec = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -swb";
                on-click = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -t -sw";
                on-click-right = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -d -sw";
                escape = true;
              };
              # "mpris" = {
              #   format = "{player_icon} {dynamic}";
              #   format-paused = "{status_icon} <i>{dynamic}</i>";
              #   player-icons = {
              #     default = "▶️";
              #   };
              #   status-icons = {
              #     paused = "⏸";
              #   };
              # };
              "niri/workspaces" = {
                format = "{icon}";
                format-icons = {
                  terminal = "";
                  notes = "󰂺";
                  browser = "󰈹";
                  communication = "󰭹";
                };
              };
              "privacy" = {
                icon-size = globalIconSize;
                modules = [
                  { type = "screenshare"; }
                  { type = "audio-in"; }
                  { type = "audio-out"; }
                ];
              };
              "systemd-failed-units" = {
                "hide-on-ok" = true;
                "format" = "✗  {nr_failed}";
                "system" = true;
                "user" = true;
              };
              "tray" = {
                icon-size = globalIconSize - 4;
                spacing = 10;
                reverse-direction = true;
              };
              "wireplumber" = {
                format = "{volume}%  {icon}";
                format-muted = "";
                on-click = "${lib.getExe hmConfig.services.playerctld.package} play-pause";
                on-click-right = "${lib.getExe pkgs.pavucontrol}";
                format-icons = [
                  ""
                  ""
                  ""
                ];
                scroll-step = "0.25";
              };
            });

          # Stylix injects more css than color definitions
          # However, it doesn't cover all modules and leads to inconsistency
          # https://github.com/danth/stylix/issues/429
          style = ''
            #privacy {
                padding: 0 5px;
            }
            #systemd-failed-units {
                padding: 0 5px;
            }
            #tray {
                padding: 0 5px;
            }
            #custom-notification {
                padding: 0 5px;
                font-family: "Symbols Nerd Font Mono";
            }
          '';
        };

        systemd.user.services.waybar.Unit.After = [ "graphical-session.target" ];

      };

  };
}
