{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.helix;
in
{
  options.profiles.tui.helix = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    # TODO: drop this and go back to helix in nixpkgs after helix 25.01 release
    nix.settings = {
      substituters = [ "https://helix.cachix.org" ];
      trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
    };

    home-manager.users.${user} = {

      programs.helix =
        let
          themeName = "gruvbox_material_dark_medium";
        in
        {
          enable = true;
          defaultEditor = true;
          package = inputs.helix.packages.${config.nixpkgs.hostPlatform.system}.helix;

          ignores = [
            "!.github/"
            "!.gitignore"
            "!.gitattributes"
          ];

          languages = {
            language =
              let
                mkPrettierList =
                  languageList:
                  (map (lang: {
                    name = lang;
                    auto-format = true;
                    formatter = {
                      command = lib.getExe pkgs.nodePackages.prettier;
                      args = [
                        "--parser"
                        lang
                      ];
                    };
                  }) languageList);
              in
              [
                {
                  name = "cpp";
                  auto-format = true;
                }
                {
                  name = "java";
                  auto-format = true;
                  formatter = {
                    command = lib.getExe pkgs.google-java-format;
                    args = [
                      "--aosp"
                      "-"
                    ];
                  };
                  indent = {
                    tab-width = 4;
                    unit = "    ";
                  };
                }
                {
                  name = "nix";
                  auto-format = true;
                  formatter = {
                    command = lib.getExe pkgs.nixfmt-rfc-style;
                    args = [
                      "--strict"
                      "-"
                    ];
                  };
                  language-servers = [ "nixd" ];
                }
                {
                  name = "python";
                  auto-format = true;
                  formatter = {
                    command = lib.getExe pkgs.ruff;
                    args = [
                      "format"
                      "-"
                    ];
                  };
                  language-servers = [ "pyright" ];
                }
              ]
              ++ mkPrettierList [
                "json"
                "markdown"
                "yaml"
              ];
            # https://github.com/helix-editor/helix/blob/master/languages.toml
            language-server = {
              "clangd" = {
                command = lib.getExe' pkgs.clang-tools "clangd";
              };
              "jdtls" = {
                command = lib.getExe pkgs.jdt-language-server;
                # TODO: add java.jdt.ls.lombokSupport
              };
              "nixd" = {
                command = lib.getExe pkgs.nixd;
              };
              "pyright" = {
                command = lib.getExe' pkgs.pyright "pyright-langserver";
                args = [ "--stdio" ];
              };
            };
          };

          settings = {
            editor = {
              auto-save = {
                focus-lost = true;
                after-delay.enable = true;
              };
              color-modes = true;
              completion-timeout = 5;
              cursorline = true;
              cursor-shape = {
                insert = "bar";
              };
              end-of-line-diagnostics = "hint";
              idle-timeout = 10;
              inline-diagnostics = {
                cursor-line = "warning";
                other-lines = "error";
              };
              indent-guides = {
                render = true;
                skip-levels = 1;
              };
              line-number = "relative";
              lsp = {
                display-messages = true;
              };
              soft-wrap = {
                enable = true;
              };
            };

            keys =
              let
                commonKeys = {
                  "pageup" = "half_page_up";
                  "pagedown" = "half_page_down";
                };
              in
              {
                normal = { } // commonKeys;
                select = { } // commonKeys;
                insert = { } // commonKeys;
              };

            theme = themeName;
          };

          # https://github.com/CptPotato/helix-themes
          themes = {
            ${themeName} = lib.importTOML ./themes.toml;
          };
        };

      stylix.targets.helix.enable = false;
    };

  };

}
