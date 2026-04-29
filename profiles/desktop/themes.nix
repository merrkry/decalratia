{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.themes;
  hmConfig = config.home-manager.users.${user};

  iconThemeName = "Papirus-Dark";
in
{
  options.profiles.desktop.themes = {
    enable = lib.mkEnableOption "themes";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      gtk =
        let
          shareConfig = {
            gtk-im-module = "fcitx";
            gtk-decoration-layout = "menu:none"; # doesn't work
          };
        in
        {
          enable = true;

          theme = {
            name = "Adwaita-dark";
            package = pkgs.gnome-themes-extra;
          };

          iconTheme = {
            name = iconThemeName;
            package = pkgs.papirus-icon-theme; # pkgs.adwaita-icon-theme;
          };

          font = {
            name = "sans-serif";
            size = config.profiles.desktop.fontSizes.application;
          };

          gtk2 = {
            configLocation = "${hmConfig.xdg.configHome}/gtk-2.0/gtkrc";
            extraConfig = ''
              gtk-im-module="fcitx"
            '';
          };
          gtk3.extraConfig = { } // shareConfig;
          gtk4 = {
            inherit (hmConfig.gtk) theme;
            extraConfig = { } // shareConfig;
          };
        };

      home = {
        # https://wiki.nixos.org/wiki/GNOME#To_run_GNOME_programs_outside_of_GNOME
        packages = with pkgs; [
          adwaita-icon-theme
          gnome-themes-extra
        ];

        pointerCursor = {
          enable = true;
          name = "Adwaita";
          package = pkgs.adwaita-icon-theme;

          gtk.enable = true;
          x11.enable = true;
        };
      };

      # https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3
      qt =
        let
          qtctSettings = {
            Appearance = {
              icon_theme = iconThemeName;
            };

            Fonts = {
              fixed = ''"monospace,${toString config.profiles.desktop.fontSizes.application}"'';
              general = ''"sans-serif,${toString config.profiles.desktop.fontSizes.terminal}"'';
            };
          };
        in
        {
          enable = true;
          platformTheme.name = "qtct";
          style = {
            name = "kvantum";
            # package = null; # Inferred automatically
          };

          qt5ctSettings = qtctSettings;
          qt6ctSettings = qtctSettings;
        };

      xdg.configFile =
        let
          themeName = "KvLibadwaita";
          themePath = "${pkgs.kvlibadwaita-kvantum}/share/Kvantum/${themeName}";
        in
        {
          "Kvantum/kvantum.kvconfig".text = ''
            [General]
            theme=${themeName}Dark
          '';
          "Kvantum/${themeName}".source = themePath;
          "Kvantum/${themeName}Dark".source = themePath;
        };
    };
  };
}
