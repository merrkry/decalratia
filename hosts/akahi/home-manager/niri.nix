{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  xDisplay = 42;
  genDaemonUnit = command: {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = command;
      Restart = "on-failure";
    };
  };
in
{
  programs.niri = {
    settings = {
      prefer-no-csd = true;

      spawn-at-startup = [
        {
          command = [
            "fcitx5"
            "-d"
            "--replace"
          ];
        }
        {
          command = [
            "wl-paste"
            "--watch"
            "cliphist"
            "store"
          ];
        }
      ];

      binds =
        with config.lib.niri.actions;
        {
          "Mod+D".action = spawn "rofi" "-show" "drun";
          "Mod+T".action = spawn "foot";
          "Mod+Alt+L".action = spawn "swaylock";
          "Alt+T".action = spawn "foot";
          "Mod+Q".action = close-window;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+F".action = maximize-column;
          "Mod+V".action = spawn "sh" "-c" "cliphist list | rofi -dmenu | cliphist decode | wl-copy";
          "Mod+Shift+V".action = spawn "sh" "-c" "cliphist wipe";
          "Print".action = screenshot;

          # Window management
          # Mod: focus
          # +Ctrl: window/column
          # +Alt: workspace
          # +Shift: monitor

          "Mod+Left".action = focus-column-left;
          "Mod+Right".action = focus-column-right;
          "Mod+Up".action = focus-window-or-workspace-up;
          "Mod+Down".action = focus-window-or-workspace-down;

          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Right".action = move-column-right;

          "Mod+Alt+Up".action = move-workspace-up;
          "Mod+Alt+Down".action = move-workspace-down;

          "Mod+Ctrl+Up".action = move-window-up-or-to-workspace-up;
          "Mod+Ctrl+Down".action = move-window-down-or-to-workspace-down;

          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";

          "Mod+Shift+E".action = quit;
        }
        // (
          let
            workspaceList = builtins.genList (x: x + 1) 9;
            genNumberedBinds =
              key: action:
              (builtins.listToAttrs (
                map (x: {
                  name = "${key}+${toString x}";
                  value = {
                    action = action x;
                  };
                }) workspaceList
              ));
          in
          (genNumberedBinds "Mod" focus-workspace)
          // (genNumberedBinds "Mod+Ctrl" move-column-to-workspace)
          # exception here, Alt is used for window operation
          // (genNumberedBinds "Mod+Alt" move-window-to-workspace)
        );

      workspaces = {
        # will be sorted by key in generated config
        "0" = {
          name = "terminal";
        };
        "1" = {
          name = "browser";
        };
        "2" = {
          name = "notes";
        };
        "3" = {
          name = "communication";
        };
      };

      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      hotkey-overlay.skip-at-startup = true;

      input = {
        touchpad = {
          dwt = true; # disabled when typing
          natural-scroll = false;
        };
        # comma separated, see xkeyboard-config(7)
        keyboard.xkb.options = "caps:swapescape";
      };

      outputs = {
        "eDP-1" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 165.003;
          };
          scale = 1.6;
          variable-refresh-rate = true; # "on-demand"; # may cause flickering
        };
      };

      environment = {
        # LANG = "zh_CN.UTF-8";
        DISPLAY = ":${toString xDisplay}";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };

      layout = {
        gaps = 6;
        default-column-width.proportion = 1.0;
      };

      window-rules = [
        {
          matches = [
            { app-id = "^foot$"; }
            { app-id = "^Thunar$"; }
            { app-id = "^org\.kde\.ark$"; }
          ];
          default-column-width.proportion = 0.5;
        }
        {
          matches = [
            # minial width will exceed 0.5 after theming, weired
            { app-id = "^org\.prismlauncher\.PrismLauncher$"; }
          ];
          default-column-width.proportion = 0.6;
        }
        {
          matches = [
            {
              app-id = "^chrome-nngceckbapebfimnlniiiahkandclblb-Default$";
              # won't work with title rule
              # guess it's not the original title at startup
              # title = "^Bitwarden$";
            }
          ];
          default-column-width.proportion = 0.2;
        }
        {
          matches = [
            { app-id = "^chromium-browser$"; }
            { app-id = "^firefox$"; }
          ];
          open-on-workspace = "browser";
        }
        {
          matches = [ { app-id = "^obsidian$"; } ];
          open-on-workspace = "notes";
        }
        {
          matches = [
            { app-id = "^io\.github\.kukuruzka165\.materialgram$"; }
            { app-id = "^thunderbird$"; }
          ];
          open-on-workspace = "communication";
        }
      ];

    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${lib.getExe pkgs.foot}";
  };

  programs.foot.enable = true;

  programs.swaylock.enable = true;

  services.swaync = {
    enable = true;
    # https://man.archlinux.org/man/swaync.5.en
    settings = {
      timeout = 5;
      timeout-low = 5;
      timeout-critical = 5;
    };
  };

  home.packages = with pkgs; [
    xwayland-run
    cage
    wl-clipboard
    cliphist
    bluetuith
    playerctl # services.playerctld doesn't import this'
    networkmanagerapplet # nmtui/nmcli can't detect gnome-keyring
    brightnessctl
  ];

  # not working
  xresources.properties = {
    "Xft.dpi" = 96;
  };

  systemd.user.services = {
    "xwayland-satellite" = genDaemonUnit "${lib.getExe pkgs.xwayland-satellite} :${toString xDisplay}";
    "nm-applet" = genDaemonUnit "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"} --indicator"; # maybe the nixos module in nixpkgs is better?
  };
}
