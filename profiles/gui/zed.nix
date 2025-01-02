{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.zed;
in
{
  options.profiles.gui.zed = {
    enable = lib.mkEnableOption' { };
    enableAI = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.zed-editor = {
        enable = true;
        userSettings = lib.mkMerge [
          {
            ui_font_size = 16;
            buffer_font_size = 14;
            theme = {
              mode = "system";
              light = "Gruvbox Light Soft";
              dark = "Gruvbox Dark Soft";
            };
            telemetry = {
              diagnostics = false;
              metrics = false;
            };
            vim_mode = true;
            languages = {
              "C++" = {
                format_on_save = "on";
              };
              "Java" = {
                format_on_save = "on";
                formatter.external = {
                  command = "${lib.getExe pkgs.google-java-format}";
                  arguments = [
                    "--aosp"
                    "-" # read from stdin
                  ];
                };
              };
              "Markdown" = {
                soft_wrap = "editor_width";
              };
              "Nix" = {
                tab_size = 2;
                # formatter = "language_server"; # seems no way to pass any args to nixd
                formatter.external = {
                  command = "${lib.getExe pkgs.nixfmt-rfc-style}";
                  arguments = [ "--strict" ];
                };
                format_on_save = "on";
                enable_language_server = true;
                hard_tabs = false;
                language_servers = [ "nixd" ];
              };
              "Python" = {
                format_on_save = "on";
                formatter.external = {
                  command = "${lib.getExe pkgs.ruff}";
                  arguments = [
                    "format"
                    "-"
                  ];
                };
              };
            };
            lsp = {
              "clangd" = {
                binary.path = "${lib.getExe' pkgs.clang-tools "clangd"}";
              };
              "jdtls" = {
                binary.path = "${lib.getExe pkgs.jdt-language-server}";
                initialization_options.settings.java.jdt.ls.lombokSupport.enabled = true;
              };
              "nixd" = {
                binary.path = "${lib.getExe pkgs.nixd}";
              };
            };
            notification_panel = {
              dock = "left";
              button = false;
            };
            collaboration_panel.button = false;
          }
          (
            if cfg.enableAI then
              {
                assistant = {
                  default_model = {
                    provider = "copilot_chat";
                    model = "o1-mini";
                  };
                  version = "2";
                };
                features = {
                  inline_completion_provider = "copilot";
                };
              }
            else
              {
                # https://github.com/zed-industries/zed/issues/7121#issuecomment-2434482066

                features = {
                  inline_completion_provider = "none";
                  copilot = false;
                };
                assistant = {
                  enabled = false;
                  dock = "left";
                  version = "2";
                };
                assistant_v2.enabled = false;
                chat_panel = {
                  dock = "left";
                  button = false;
                };
              }
          )
        ];
      };

    };

  };

}
