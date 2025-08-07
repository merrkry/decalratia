{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.fonts;
in
{
  options.profiles.desktop.fonts = {
    enable = lib.mkEnableOption "fonts" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontDir = {
        enable = true;
        decompressFonts = true;
      };

      # https://github.com/NixOS/nixpkgs/blob/fa42b5a5f401aab8a32bd33c9a4de0738180dc59/nixos/modules/config/fonts/packages.nix#L34C1-L41C8
      enableDefaultPackages = true;

      packages = with pkgs; [
        ibm-plex
        noto-fonts

        # Many poorly written CSS code don't expect that there exits apple emoji but not apple system font.
        # Include both can avoid some weired behavior.
        apple-color-emoji
        apple-system-fonts

        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        # for compatibility with old app that doesn't support variable fonts
        nur.repos.wrvsrx.noto-fonts-cjk-sans-fix-weight
        nur.repos.wrvsrx.noto-fonts-cjk-serif-fix-weight

        bookerly
        lxgw-wenkai-screen

        fira-code
        maple-mono.CN
        nerd-fonts.symbols-only

        stix-two
      ];

      fontconfig = {
        enable = true;
        useEmbeddedBitmaps = true;

        localConf = (builtins.readFile ./fontconfig.xml);

        defaultFonts = {
          sansSerif = [
            "IBM Plex Sans"
            "Noto Sans CJK SC"
            "Noto Sans CJK TC"
            "Noto Sans CJK JP"
            "Noto Sans CJK KR"
            "Symbols Nerd Font"
          ];

          serif = [
            "Bookerly"
            "LXGW WenKai Screen"
            "Symbols Nerd Font"
          ];

          monospace = [
            "Fira Code"
            "Maple Mono CN"
            "Symbols Nerd Font Mono"
          ];

          emoji = [ "Apple Color Emoji" ];
        };

        subpixel.rgba = "rgb";
      };
    };

    stylix.fonts = {
      serif = {
        package = pkgs.emptyDirectory;
        name = "serif";
      };
      sansSerif = {
        package = pkgs.emptyDirectory;
        name = "sans-serif";
      };
      monospace = {
        package = pkgs.emptyDirectory;
        name = "monospace";
      };
      emoji = {
        package = pkgs.emptyDirectory;
        name = "emoji";
      };

      sizes = rec {
        applications = 10;
        terminal = applications + 2;
      };
    };

    # Generate the same config at user level, this can fix some (but not all of them) flatpak apps, e.g. firefox
    home-manager.users.${user} = {
      fonts.fontconfig = {
        enable = true;
        defaultFonts = config.fonts.fontconfig.defaultFonts;
      };
    };
  };
}
