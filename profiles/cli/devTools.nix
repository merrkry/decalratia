{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.devTools;
in
{
  options.profiles.cli.devTools = {
    enable = lib.mkEnableOption "devTools";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home = {
        packages = with pkgs; [
          # AI

          inputs.llm-agents.packages.${config.nixpkgs.system}.claude-code
          inputs.llm-agents.packages.${config.nixpkgs.system}.opencode

          # Universal tools

          gnumake
          meson
          mesonlsp
          ninja
          xmake

          jujutsu
          jjui

          just
          go-task

          difftastic

          lsof

          typos-lsp

          # Language toolchains

          # bash
          bash-language-server
          shfmt # used by bash-language-server automatically
          # c / cpp
          gcc
          clang-tools
          cmake
          # go
          go
          gopls
          # javascript / typescript
          bun
          deno
          nodejs
          vtsls
          # kdl
          kdlfmt
          # latex
          texlab
          tex-fmt
          # lua
          lua
          emmylua-ls
          stylua
          # nix
          nixd
          nixfmt
          statix
          # python
          python3
          pyrefly
          ruff
          uv
          # rust
          rustup
          # toml
          taplo
          # typst
          typst
          tinymist
          # yaml
          yaml-language-server
          # misc
          nodePackages.prettier
          vscode-langservers-extracted
        ];

        sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };
      };
    };
  };
}
