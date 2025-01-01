{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.themes;
in
{
  options.profiles.desktop.themes = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    stylix = {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
      cursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
      image = lib.mkDefault (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-nineish-dark-gray.png";
          sha256 = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
        }
      );
      polarity = "dark";
      targets = {
        nixos-icons.enable = false; # completely desktroys the design
      };
    };

    home-manager.users.${user} =
      let
        hmConfig = config.home-manager.users.${user};
      in
      {
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

        programs = {
          swaybg = {
            enable = true;
            image = lib.mkDefault config.stylix.image;
          };
        };

        # https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3
        qt = {
          enable = true;
          platformTheme.name = "qtct";
          style.name = "kvantum"; # "adwaita-dark";
          # style.package = pkgs.adwaita-qt;
        };

        stylix.targets = {
          kde.enable = false;
        };

        xdg.configFile =
          let
            themeName = "KvLibadwaita";
          in
          {
            "Kvantum/kvantum.kvconfig".text = ''
              [General]
              theme=${themeName}Dark
            '';
            "Kvantum/${themeName}".source = "${pkgs.kvlibadwaita-kvantum}/share/Kvantum/${themeName}";
          };
      };

  };
}
