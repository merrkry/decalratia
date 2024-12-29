{
  config,
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

    home-manager.users.${user} = {

      programs.helix =
        let
          themeName = "gruvbox_material_dark_medium";
        in
        {
          enable = true;
          defaultEditor = true;

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
              cursorline = true;
              cursor-shape = {
                insert = "bar";
              };
              idle-timeout = 10;
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
