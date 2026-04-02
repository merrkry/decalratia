{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.kitty;
in
{
  options.profiles.gui.kitty = {
    enable = lib.mkEnableOption "kitty";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.kitty = {
        enable = true;
        settings = rec {
          # https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
          # symbol_map = "U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ea60-U+ec1e,U+ed00-U+efce,U+f000-U+f2ff,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono";

          cursor_trail = 1;
          enable_audio_bell = "no";
          clear_all_shortcuts = "yes";

          italic_font = "family=\"Maple Mono CN\"";
          bold_italic_font = italic_font;

          tab_bar_edge = "top";
          tab_bar_align = "center";
        };
        # https://sw.kovidgoyal.net/kitty/conf/#keyboard-shortcuts
        keybindings = {
          "ctrl+shift+c" = "copy_to_clipboard";
          "ctrl+shift+v" = "paste_from_clipboard";
          "ctrl+shift+o" = "open_url_with_hints";
          "ctrl+shift+up" = "scroll_line_up";
          "ctrl+shift+down" = "scroll_line_down";
          "ctrl+shift+left" = "move_tab_backward";
          "ctrl+shift+right" = "move_tab_forward";
          "ctrl+shift+h" = "previous_tab";
          "ctrl+shift+j" = "scroll_page_down";
          "ctrl+shift+k" = "scroll_page_up";
          "ctrl+shift+l" = "next_tab";
          "ctrl+shift+t" = "new_tab_with_cwd";
          "ctrl+shift+q" = "close_tab";
          "ctrl+shift+0" = "change_font_size current 0";
          "ctrl+shift+equal" = "change_font_size current +2.0";
          "ctrl+shift+minus" = "change_font_size current -2.0";
          "ctrl+shift+escape" = "kitty_shell";
          "ctrl+shift+tab" = "select_tab";
        };
        environment = {
          LANG = "en_US.UTF-8";
        };
      };

      stylix.targets.kitty.enable = true;
    };
  };
}
