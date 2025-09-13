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
          cursor_trail = 1;
          enable_audio_bell = "no";
          # clear_all_shortcuts = "yes";

          italic_font = "family=\"Maple Mono CN\"";
          bold_italic_font = italic_font;

          tab_bar_edge = "top";
        };
        # https://sw.kovidgoyal.net/kitty/conf/#keyboard-shortcuts
        keybindings = {
          "ctrl+shift+c" = "copy_to_clipboard";
          "ctrl+shift+v" = "paste_from_clipboard";
          "ctrl+shift+up" = "scroll_line_up";
          "ctrl+shift+k" = "scroll_line_up";
          "ctrl+shift+down" = "scroll_line_down";
          "ctrl+shift+j" = "scroll_line_down";
          "ctrl+shift+page_up" = "scroll_page_up";
          "ctrl+shift+page_down" = "scroll_page_down";
          "ctrl+shift+equal" = "change_font_size all +2.0";
          "ctrl+shift+minus" = "change_font_size all -2.0";
          "ctrl+shift+backspace" = "change_font_size all 0";
        };
        environment = {
          LANG = "en_US.UTF-8";
        };
      };

      stylix.targets.kitty.enable = true;
    };
  };
}
