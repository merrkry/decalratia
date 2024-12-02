{
  config,
  lib,
  pkgs,
  ...
}:
{
  stylix = {
    enable = true;

    polarity = "dark";

    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/refs/heads/master/wallpapers/nix-wallpaper-nineish-dark-gray.png";
      sha256 = "sha256-nhIUtCy/Hb8UbuxXeL3l3FMausjQrnjTVi1B3GkL9B8=";
    };

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";

    fonts =
      let
        fontPlaceholder = pkgs.noto-fonts;
      in
      {
        serif = {
          package = fontPlaceholder;
          name = "serif";
        };
        sansSerif = {
          package = fontPlaceholder;
          name = "sans-serif";
        };
        monospace = {
          package = fontPlaceholder;
          name = "monospace";
        };
        emoji = {
          package = fontPlaceholder;
          name = "emoji";
        };

        sizes = {
          applications = 10;
          terminal = 10;
        };
      };

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # ugly
    targets.plymouth.enable = false;
  };
}
