{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.niri;
in
{
  options.profiles.desktop.niri = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    programs.niri = {
      enable = true;
      package = pkgs.niri;
    };

    home-manager.users.${user} =
      let
        hmConfig = config.home-manager.users.${user};
        xDisplay = 42;
      in
      {

        programs.niri =
          let
            terminal = "${lib.getExe hmConfig.programs.foot.package}";
            cliphist = "${lib.getExe pkgs.cliphist}";
            rofi = "${lib.getExe hmConfig.programs.rofi.package}";
          in
          {
            settings = {
              prefer-no-csd = true;

              spawn-at-startup = [
                {
                  command = [
                    "${lib.getExe' pkgs.wl-clipboard "wl-paste"}"
                    "--watch"
                    "${cliphist}"
                    "store"
                  ];
                }
                {
                  command = [
                    "${lib.getExe' pkgs.networkmanagerapplet "nm-applet"}"
                    "--indicator"
                  ];
                }
              ];

              binds =
                # Window management
                # Mod: focus
                # +Ctrl: window/column
                # +Alt: workspace
                # +Shift: monitor
                with hmConfig.lib.niri.actions;
                lib.mkMerge [
                  {
                    "Mod+D".action.spawn = [
                      rofi
                      "-show"
                      "drun"
                    ];
                    "Mod+T".action.spawn = [ terminal ];
                    "Mod+O".action.spawn = [ "${lib.getExe hmConfig.programs.swaylock.package}" ];
                    "Mod+E".action.spawn = [
                      terminal
                      "${lib.getExe hmConfig.programs.yazi.package}"
                    ];
                    "Mod+Q".action = close-window;
                    "Mod+Shift+M".action = fullscreen-window;
                    "Mod+M".action = maximize-column;
                    "Mod+C".action = center-column;
                    "Mod+V".action.spawn = [
                      "sh"
                      "-c"
                      "${cliphist} list | ${rofi} -dmenu | ${cliphist} decode | ${lib.getExe' pkgs.wl-clipboard "wl-copy"}"
                    ];
                    # `cliphist wipe` doesnt reset the index, see https://github.com/sentriz/cliphist/issues/39
                    "Mod+Shift+V".action.spawn = [
                      "sh"
                      "-c"
                      "rm ${hmConfig.xdg.cacheHome}/cliphist/db"
                    ];
                    "Print".action = screenshot;
                    "Mod+Shift+E".action = quit;
                    "Mod+Minus".action = set-column-width "-5%";
                    "Mod+BracketLeft".action = set-column-width "-25%";
                    "Mod+Equal".action = set-column-width "+5%";
                    "Mod+BracketRight".action = set-column-width "+25%";
                    "XF86MonBrightnessDown".action.spawn = [
                      "${lib.getExe pkgs.brightnessctl}"
                      "set"
                      "5%-"
                    ];
                    "XF86MonBrightnessUp".action.spawn = [
                      "${lib.getExe pkgs.brightnessctl}"
                      "set"
                      "+5%"
                    ];
                  }
                  (
                    let
                      mkVerticalBindsList = sharedKeys: mkAction: {
                        "${sharedKeys}+Up".action = hmConfig.lib.niri.actions.${mkAction "up"};
                        "${sharedKeys}+K".action = hmConfig.lib.niri.actions.${mkAction "up"};
                        "${sharedKeys}+Down".action = hmConfig.lib.niri.actions.${mkAction "down"};
                        "${sharedKeys}+J".action = hmConfig.lib.niri.actions.${mkAction "down"};
                      };
                      mkHorizontalBindsList = sharedKeys: mkAction: {
                        "${sharedKeys}+Left".action = hmConfig.lib.niri.actions.${mkAction "left"};
                        "${sharedKeys}+H".action = hmConfig.lib.niri.actions.${mkAction "left"};
                        "${sharedKeys}+Right".action = hmConfig.lib.niri.actions.${mkAction "right"};
                        "${sharedKeys}+L".action = hmConfig.lib.niri.actions.${mkAction "right"};
                      };
                      mkDirectedBindsList =
                        sharedKeys: mkAction:
                        (lib.mkMerge [
                          (mkVerticalBindsList sharedKeys mkAction)
                          (mkHorizontalBindsList sharedKeys mkAction)
                        ]);
                    in
                    lib.mkMerge [
                      (mkHorizontalBindsList "Mod" (d: "focus-column-${d}"))
                      (mkVerticalBindsList "Mod" (d: "focus-window-or-workspace-${d}"))
                      (mkHorizontalBindsList "Mod+Ctrl" (d: "move-column-${d}"))
                      (mkHorizontalBindsList "Mod+Alt" (d: "consume-or-expel-window-${d}"))
                      (mkVerticalBindsList "Mod+Ctrl+Alt" (d: "move-workspace-${d}"))
                      (mkDirectedBindsList "Mod+Ctrl+Alt+Shift" (d: "move-workspace-to-monitor-${d}"))
                      (mkVerticalBindsList "Mod+Ctrl" (d: "move-window-${d}-or-to-workspace-${d}"))
                    ]
                  )
                  (
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
                    (genNumberedBinds "Mod" focus-workspace) // (genNumberedBinds "Mod+Ctrl" move-column-to-workspace)
                  )
                ];

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
                  dwtp = true; # disabled when trackpoint
                  natural-scroll = false;
                };
                # comma separated, see xkeyboard-config(7)
                # keyboard.xkb.options = "caps:swapescape"; # replaced by xremap, which also works on xwayland
                warp-mouse-to-focus = true;
                focus-follows-mouse.enable = true;
                workspace-auto-back-and-forth = true;
              };

              cursor = {
                hide-when-typing = true;
                hide-after-inactive-ms = 10000;
              };

              environment = {
                # LANG = "zh_CN.UTF-8";
                DISPLAY = ":${toString xDisplay}";
                QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
              };

              layout = {
                gaps = 6;
                default-column-width.proportion = 0.5;
                always-center-single-column = true;
              };

              window-rules = [
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
                  default-column-width.proportion = 1.0;
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

        home.packages = with pkgs; [
          xwayland-run
          cage
        ];

        systemd.user.services = {
          "xwayland-satellite" = {
            Install = {
              WantedBy = [ "graphical-session.target" ];
            };
            Unit = {
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              ExecStart = "${lib.getExe pkgs.xwayland-satellite} :${toString xDisplay}";
              Restart = "on-failure";
            };
          };
        };

      };

  };
}
