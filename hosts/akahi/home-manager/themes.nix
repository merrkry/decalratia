{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  stylix.targets = {
    vscode.enable = false;
    firefox.enable = false;
    kde.enable = false;
  };

  gtk =
    let
      shareConfig = {
        gtk-im-module = "fcitx";
        # doesn't work
        gtk-decoration-layout = "menu:none";
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
        configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        extraConfig = ''
          gtk-im-module="fcitx"
        '';
      };

      gtk3.extraConfig = { } // shareConfig;

      gtk4.extraConfig = { } // shareConfig;
    };

  # https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3

  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum"; # "adwaita-dark";
    # style.package = pkgs.adwaita-qt;
  };

  # FIXME: impure: relies on manual install https://github.com/GabePoel/KvLibadwaita
  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=KvLibadwaitaDark
    '';
  };
}
