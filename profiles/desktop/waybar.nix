{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.waybar;
  hmConfig = config.home-manager.users.${user};
  globalIconSize = 20;
  terminal = "${lib.getExe hmConfig.programs.foot.package}";
in
{
  options.profiles.desktop.waybar = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    backlightDevice = lib.mkOption {
      type = lib.types.str;
      default = null;
      description = "The backlight device to control";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = [
          {
            reload_style_on_change = true;
            layer = "top";
            spacing = 8;
            modules-left = [ "niri/workspaces" ];
            modules-center = [ "clock" ];
            modules-right = [
              "systemd-failed-units"
              "privacy"
              "mpris"
              "wireplumber"
              "backlight"
              "battery"
              "idle_inhibitor"
              "group/minimized"
            ];
            "backlight" = {
              device = cfg.backlightDevice;
              format = "{percent}% {icon}";
              format-icons = [
                "󱩎"
                "󱩏"
                "󱩐"
                "󱩑"
                "󱩒"
                "󱩓"
                "󱩔"
                "󱩕"
                "󱩖"
                "󰛨"
              ];
              # too sensitive :(
              on-scroll-up = "${lib.getExe pkgs.brightnessctl} set +1%";
              on-scroll-down = "${lib.getExe pkgs.brightnessctl} set 1%-";
            };
            "battery" = {
              format = "{capacity}% {icon}";
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
              tooltip = true;
              format = "{:%H:%M}";
              tooltip-format = "{:%F, %a, %R}";
            };
            # https://github.com/ErikReider/SwayNotificationCenter?tab=readme-ov-file#waybar-example
            "custom/notification" = {
              tooltip = false;
              format = "{icon}   "; # workaround, add padding on the right edge of the bar
              format-icons = {
                notification = "󱅫";
                none = "󰂚";
                dnd-notification = "󱅫";
                dnd-none = "󱏩";
                inhibited-notification = "󱅫";
                inhibited-none = "󱏧";
                dnd-inhibited-notification = "󱅫";
                dnd-inhibited-none = "󰂛";
              };
              return-type = "json";
              exec-if = "which swaync-client"; # TODO: check services.swaync.enable
              exec = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -swb";
              on-click = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -t -sw";
              on-click-right = "${lib.getExe' hmConfig.services.swaync.package "swaync-client"} -d -sw";
              escape = true;
            };
            "group/minimized" = {
              orientation = "horizontal";
              modules = [
                "custom/notification"
                "tray"
              ];
              drawer = {
                transition-duration = 500;
              };
            };
            "idle_inhibitor" = {
              format = "{icon}";
              format-icons = {
                activated = "";
                deactivated = "";
              };
            };
            "mpris" = {
              format = "{player_icon}";
              format-paused = "{status_icon}";
              player-icons = {
                default = "";
              };
              status-icons = {
                paused = "";
              };
            };
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
              "format" = "✗ {nr_failed}";
              "system" = true;
              "user" = true;
            };
            "tray" = {
              icon-size = globalIconSize - 4;
              spacing = 10;
              reverse-direction = true;
            };
            "wireplumber" = {
              format = "{volume}% {icon}";
              format-muted = "{volume}% ";
              on-click = "${lib.getExe' pkgs.wireplumber "wpctl"} set-mute @DEFAULT_AUDIO_SINK@ toggle";
              on-click-right = "${lib.getExe pkgs.pavucontrol}";
              format-icons = [
                ""
                ""
                ""
              ];
              scroll-step = "0.25";
            };
          }
        ];

        # Stylix injects more css than color definitions
        # However, it doesn't cover all modules and leads to inconsistency
        # https://github.com/danth/stylix/issues/429
        style = ''
          #mpris {
              padding: 0 5px;
          }
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
          }
        '';
      };

      services.network-manager-applet.enable = true;

      stylix.targets.waybar = {
        enable = true;
        addCss = true;
      };

      systemd.user.services.waybar.Unit.After = [ "graphical-session.target" ];
    };
  };
}
