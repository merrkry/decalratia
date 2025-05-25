{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.i18n;
in
{
  options.profiles.desktop.i18n = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {
    # to use svg themes
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];

    i18n = {
      defaultLocale = "en_US.UTF-8";
      supportedLocales = [
        "zh_CN.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          addons = with pkgs; [
            fcitx5-mellow-themes
            (fcitx5-rime.override {
              rimeDataPkgs = [
                rime-data
                nur.repos.xddxdd.rime-ice
                nur.repos.xddxdd.rime-zhwiki
                nur.repos.xddxdd.rime-moegirl
              ];
            })
          ];
          plasma6Support = true;
          waylandFrontend = true;
        };
      };
    };

    home-manager.users.${user} = {
      home.sessionVariables = lib.mkMerge [
        {
          LANG = "zh_CN.UTF-8";
          XMODIFIERS = "@im=fcitx";
        }
        (lib.optionalAttrs (!config.services.desktopManager.plasma6.enable) {
          GTK_IM_MODULE = "wayland"; # `wayland` to use tiv3, `fcitx` to use fcitx im module
          QT_IM_MODULE = "fcitx";
          QT_IM_MODULES = "wayland;fcitx;ibus";
        })
      ];

      systemd.user.services = {
        "fcitx5" = {
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
          Unit = {
            PartOf = [ "graphical-session.target" ];
            After = [
              "graphical-session.target"
              "xwayland-satellite.service"
            ];
          };
          Service = {
            ExecStart = "${lib.getExe' config.i18n.inputMethod.package "fcitx5"} --replace";
            Restart = "on-failure";
          };
        };
      };

      # TODO: refactor
      # https://github.com/xddxdd/nixos-config/blob/a2b7311f03e9dc121f0b3fc844b31068fa076066/nixos/client-apps/fcitx/rime-lantian-custom.nix

      xdg = {
        autostart = {
          enable = true;
          entries = [
            (pkgs.writeText "org.fcitx.Fcitx5.desktop" ''
              [Desktop Entry]
              Type=Application
              Name=Fcitx 5
              Hidden=true
            '')
          ];
        };

        dataFile = {
          "fcitx5/rime/default.custom.yaml".text = ''
            patch:
              __include: rime_ice_suggestion:/
              schema_list:
                - schema: rime_ice
          '';

          "fcitx5/rime/rime_ice.custom.yaml".text = ''
            patch:
              "translator/dictionary": custom_dict
          '';

          "fcitx5/rime/custom_dict.dict.yaml".text = ''
            # Rime dictionary
            # encoding: utf-8

            ---
            name: custom_dict
            version: "1.0"
            sort: by_weight
            use_preset_vocabulary: false
            import_tables:
              # https://github.com/iDvel/rime-ice/blob/main/rime_ice.dict.yaml
              - cn_dicts/8105     # 字表
              - cn_dicts/41448    # 大字表（按需启用）（启用时和 8105 同时启用并放在 8105 下面）
              - cn_dicts/base     # 基础词库
              - cn_dicts/ext      # 扩展词库
              - cn_dicts/tencent  # 腾讯词向量（大词库，部署时间较长）
              - cn_dicts/others   # 一些杂项

              - zhwiki
              - moegirl
            ...
          '';
        };
      };
    };
  };
}
