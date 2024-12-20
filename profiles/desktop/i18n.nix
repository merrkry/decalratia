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
            libsForQt5.fcitx5-qt
            fcitx5-gtk
            fcitx5-configtool
            fcitx5-chinese-addons
            (fcitx5-rime.override {
              rimeDataPkgs = [
                rime-data
                nur.repos.xddxdd.rime-ice
                nur.repos.xddxdd.rime-zhwiki
                nur.repos.xddxdd.rime-moegirl
              ];
            })
          ];
          waylandFrontend = true;
        };
      };
    };

    home-manager.users.${user} = {

      # TODO: refactor
      # https://github.com/xddxdd/nixos-config/blob/a2b7311f03e9dc121f0b3fc844b31068fa076066/nixos/client-apps/fcitx/rime-lantian-custom.nix

      xdg.dataFile = {
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
}
