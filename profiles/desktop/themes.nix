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
in
{
  options.profiles.desktop.themes = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      cursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
      image = lib.mkDefault (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-nineish-dark-gray.svg";
          sha256 = "sha256-r+2MyWWfr7f3kzmsPI24hReScVaJtdmGO0drISs1NGM=";
        }
      );
      polarity = "dark";
      opacity.terminal = 0.85;
      targets = {
        gnome.enable = true;
        gtk.enable = true;
        qt.enable = true;
      };
    };

    home-manager.users.${user} = {
      gtk =
        let
          shareConfig = {
            gtk-im-module = "fcitx";
            gtk-decoration-layout = "menu:none"; # doesn't work
          };
        in
        {
          enable = true;

          # covered by stylix
          # theme = {
          #   name = "adw-gtk3";
          #   package = pkgs.adw-gtk3;
          # };

          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme; # pkgs.adwaita-icon-theme;
          };

          # covered by stylix
          # cursorTheme = {
          #   name = "Adwaita";
          #   package = pkgs.adwaita-icon-theme;
          # };

          gtk2 = {
            configLocation = "${hmConfig.xdg.configHome}/gtk-2.0/gtkrc";
            extraConfig = ''
              gtk-im-module="fcitx"
            '';
          };
          gtk3.extraConfig = { } // shareConfig;
          gtk4.extraConfig = { } // shareConfig;
        };

      # https://wiki.nixos.org/wiki/GNOME#To_run_GNOME_programs_outside_of_GNOME
      home.packages = with pkgs; [
        adwaita-icon-theme
        gnome-themes-extra
      ];

      programs = {
        swaybg = {
          enable = true;
          image = lib.mkDefault config.stylix.image;
        };
      };

      # https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3
      qt = {
        enable = true; # Let stylix handle everything else
        # platformTheme.name = "qtct";
        # style.name = "kvantum"; # "adwaita-dark";
        # style.package = pkgs.adwaita-qt;
      };

      stylix.targets = {
        gtk.enable = config.stylix.targets.gtk.enable;
        gnome.enable = config.stylix.targets.gnome.enable;
        kde.enable = true;
        qt.enable = config.stylix.targets.qt.enable;
      };

      # xdg.configFile =
      #   let
      #     themeName = "KvLibadwaita";
      #   in
      #   {
      #     "Kvantum/kvantum.kvconfig".text = ''
      #       [General]
      #       theme=${themeName}Dark
      #     '';
      #     "Kvantum/${themeName}".source = "${pkgs.kvlibadwaita-kvantum}/share/Kvantum/${themeName}";
      #   };
    };
  };
}
