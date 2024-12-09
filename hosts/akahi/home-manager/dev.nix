{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  home.packages = with pkgs; [ lunarvim ];

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
    enableBashIntegration = false;

    settings = {
      nix_shell = {
        heuristic = true;
      };
    };
  };

  programs.helix = {
    enable = true;
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${lib.getExe pkgs.nixfmt-rfc-style} --strict";
      }
    ];
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {

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
      features = {
        inline_completion_provider = "copilot";
      };
      assistant = {
        default_model = {
          provider = "copilot_chat";
          model = "o1-mini";
        };
        version = "2";
      };
      languages = {
        "Nix" = {
          tab_size = 2;
          # formatter = "language_server"; # seems no way to pass any args to nixd
          formatter.external = {
            command = "nixfmt";
            arguments = [ "--strict" ];
          };
          format_on_save = "on";
          enable_language_server = true;
          hard_tabs = false;
          language_servers = [ "nixd" ];
        };
      };
      lsp = {
        jdtls = {
          initialization_options.settings.java.jdt.ls.lombokSupport.enabled = true;
        };
      };

    };
  };
}
