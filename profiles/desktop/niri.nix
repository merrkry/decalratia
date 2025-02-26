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
  hmConfig = config.home-manager.users.${user};
  screenshotsPath = "${hmConfig.xdg.userDirs.pictures}/Screenshots";
in
{
  options.profiles.desktop.niri = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    useUpstreamPackage = lib.mkEnableOption { };
  };

  config = lib.mkIf cfg.enable {

    nixpkgs.overlays = [ inputs.niri-flake.overlays.niri ];

    programs.niri = {
      enable = true;
      package = if cfg.useUpstreamPackage then pkgs.niri-unstable else pkgs.niri;
    };

    home-manager.users.${user} =
      let
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
                    "Mod+F".action = switch-focus-between-floating-and-tiling;
                    "Mod+Shift+f".action = toggle-window-floating;
                    "Mod+C".action = center-column;
                    "Mod+BracketLeft".action = consume-or-expel-window-left;
                    "Mod+BracketRight".action = consume-or-expel-window-right;
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
                    "Mod+Minus".action = set-column-width "-10%";
                    "Mod+Shift+Minus".action = set-window-height "-10%";
                    "Mod+Equal".action = set-column-width "+10%";
                    "Mod+Shift+Equal".action = set-window-height "+10%";
                    "Mod+R".action = switch-preset-column-width;
                    "Mod+Shift+R".action = reset-window-height;
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
                      mkVerticalBindsList' = sharedKeys: mkAction: {
                        "${sharedKeys}+Page_Up".action = hmConfig.lib.niri.actions.${mkAction "up"};
                        "${sharedKeys}+I".action = hmConfig.lib.niri.actions.${mkAction "up"};
                        "${sharedKeys}+Page_Down".action = hmConfig.lib.niri.actions.${mkAction "down"};
                        "${sharedKeys}+U".action = hmConfig.lib.niri.actions.${mkAction "down"};
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
                      mkVerticalScrollBindsList = sharedKeys: mkAction: {
                        "${sharedKeys}+WheelScrollUp" = {
                          cooldown-ms = 150;
                          action = hmConfig.lib.niri.actions.${mkAction "up"};
                        };
                        "${sharedKeys}+WheelScrollDown" = {
                          cooldown-ms = 150;
                          action = hmConfig.lib.niri.actions.${mkAction "down"};
                        };
                      };
                      # there seems to be natural scroll
                      mkHorizontalScrollBindsList = sharedKeys: mkAction: {
                        "${sharedKeys}+WheelScrollLeft".action = hmConfig.lib.niri.actions.${mkAction "right"};
                        "${sharedKeys}+WheelScrollRight".action = hmConfig.lib.niri.actions.${mkAction "left"};
                      };
                    in
                    lib.mkMerge [
                      (mkHorizontalBindsList "Mod" (d: "focus-column-${d}"))
                      (mkVerticalBindsList "Mod" (d: "focus-window-${d}"))
                      (mkHorizontalBindsList "Mod+Ctrl" (d: "move-column-${d}"))
                      (mkVerticalBindsList "Mod+Ctrl" (d: "move-window-${d}"))
                      (mkDirectedBindsList "Mod+Shift" (d: "focus-monitor-${d}"))
                      (mkDirectedBindsList "Mod+Shift+Ctrl" (d: "move-column-to-monitor-${d}"))
                      (mkVerticalBindsList' "Mod" (d: "focus-workspace-${d}"))
                      (mkVerticalBindsList' "Mod+Ctrl" (d: "move-column-to-workspace-${d}"))
                      (mkVerticalBindsList' "Mod+Shift" (d: "move-workspace-${d}"))
                      (mkVerticalScrollBindsList "Mod" (d: "focus-workspace-${d}"))
                      (mkHorizontalScrollBindsList "Mod" (d: "focus-column-${d}"))
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

              screenshot-path = "${screenshotsPath}/Screenshot from %Y-%m-%d %H-%M-%S.png";

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
                focus-follows-mouse.enable = false;
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
                always-center-single-column = true;
                center-focused-column = "on-overflow";
                default-column-width.proportion = 0.5;
              };

              window-rules = [
                {
                  matches = [ { title = "^_crx_nngceckbapebfimnlniiiahkandclblb$"; } ]; # Bitwarden
                  open-floating = true;
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
                    { title = "^Cinny$"; }
                    { title = "^Element$"; }
                    { app-id = "^io\.github\.kukuruzka165\.materialgram$"; }
                    { app-id = "^QQ$"; }
                    { app-id = "^thunderbird$"; }
                    { title = "^Mail - Nextcloud$"; }
                  ];
                  open-on-workspace = "communication";
                }
                # {
                #   # Somehow doesn't work as well
                #   matches = [
                #     # app-id = "^io\.github\.kukuruzka165\.materialgram$";
                #     { title = "^媒体查看器$"; }
                #     { title = "^Media viewer$"; }
                #   ];
                #   open-floating = true;
                # }
                {
                  matches = [
                    {
                      app-id = "^firefox$";
                      title = "^画中画$";
                    }
                    {
                      app-id = "^firefox$";
                      title = "^Picture-in-Picture$";
                    }
                  ];
                  open-floating = true;
                  default-floating-position = {
                    x = 32;
                    y = 32;
                    relative-to = "bottom-right";
                  };
                  default-column-width.proportion = 0.125;
                  default-window-height.proportion = 0.125;
                }
                {
                  matches = [ { app-id = "^xdg-desktop-portal-gtk$"; } ];
                  open-floating = true;
                }
              ];

            };
          };

        home.packages = with pkgs; [
          cage
          xorg.xrandr
          xwayland-run
        ];

        systemd.user = {
          services = {
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

          tmpfiles.rules = [
            "d ${screenshotsPath} - - - 14d -"
            "d ${hmConfig.xdg.userDirs.pictures}/Steam - - - 14d -"
          ];
        };

      };

  };
}
