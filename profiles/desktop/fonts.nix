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
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    fonts = {
      fontDir.enable = true;

      # https://github.com/NixOS/nixpkgs/blob/fa42b5a5f401aab8a32bd33c9a4de0738180dc59/nixos/modules/config/fonts/packages.nix#L34C1-L41C8
      enableDefaultPackages = true;

      packages = with pkgs; [
        noto-fonts
        dejavu_fonts

        noto-fonts-color-emoji

        noto-fonts-cjk-sans
        noto-fonts-cjk-serif

        # for compatibility with old app that doesn't support variable fonts
        noto-fonts-cjk-sans-static
        noto-fonts-cjk-serif-static

        bookerly
        lxgw-wenkai

        jetbrains-mono
        nerd-fonts.symbols-only

        ibm-plex
      ];

      fontconfig = {
        enable = true;
        useEmbeddedBitmaps = true;

        # https://catcat.cc/post/2021-03-07/
        localConf = ''
          <match target="pattern">
            <test name="family">
              <string>system-ui</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>sans-serif</string>
            </edit>
          </match>
        '';

        defaultFonts = {
          sansSerif = [
            "IBM Plex Sans"
            "Noto Sans CJK SC"
            "Noto Sans CJK TC"
            "Noto Sans CJK JP"
            "Noto Sans CJK KR"
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];

          serif = [
            "Bookerly"
            "LXGW WenKai"
            "Noto Serif CJK SC"
            "Noto Serif CJK TC"
            "Noto Serif CJK JP"
            "Noto Serif CJK KR"
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];

          monospace = [
            "JetBrains Mono"
            "Noto Sans Mono CJK SC"
            "Noto Sans Mono CJK TC"
            "Noto Sans Mono CJK JP"
            "Noto Sans Mono CJK KR"
            "Noto Color Emoji"
            "Symbols Nerd Font Mono"
          ];

          emoji = [ "Noto Color Emoji" ];
        };

        subpixel.rgba = "rgb";
      };
    };

    stylix.fonts =
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

    home-manager.users.${user} = {

      # TODO: generate this symlink via script
      # .local/share/fonts/system -> /run/current-system/sw/share/X11/fonts

    };

  };
}
