{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.presets.desktop;
in
{
  imports = [ ./fakehome.nix ];

  options.presets.desktop = {
    enable = lib.mkEnableOption "desktop" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {

        home.sessionVariables = {
          # Workaround for https://bugs.kde.org/show_bug.cgi?id=479891
          QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
        };

        # TODO: generate this symlink via script
        # .local/share/fonts/system -> /run/current-system/sw/share/X11/fonts

        services.gnome-keyring.enable = lib.mkDefault osConfig.services.gnome.gnome-keyring.enable;

        home.packages = with pkgs; [
          trash-cli

          xorg.xeyes
          glxinfo
          vulkan-tools
        ];

      }

      (lib.mkIf osConfig.presets.desktop.enableLocale {
        # TODO: move to standalone package
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

      })

    ]
  );
}
