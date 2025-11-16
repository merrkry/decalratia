{
  config,
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
      home.packages = with pkgs; [
        # universal
        cmake
        gnumake
        meson
        mesonlsp
        ninja
        xmake

        jujutsu

        just
        go-task

        # bash
        bash-language-server
        shfmt # used by bash-language-server automatically
        # c / cpp
        gcc
        clang-tools
        # go
        go
        gopls
        # javascript / typescript
        bun
        deno
        nodejs
        pnpm
        vtsls
        # lua
        lua
        emmylua-ls
        stylua
        # nix
        nixd
        nixfmt
        # python
        python3
        basedpyright
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

      xdg.configFile = {
        "clangd/config.yaml".text = ''
          CompileFlags:
            Add:
              - "-Wall"
              - "-Wextra"
          ---
          If:
            PathMatch:
              - ".*\\.cpp"
              - ".*\\.hpp"
          CompileFlags:
            Add:
              - "-std=c++26"
        '';
      };
    };
  };
}
