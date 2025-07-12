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
        ninja
        xmake
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
        nodejs
        pnpm
        # lua
        lua
        lua-language-server
        # nix
        nixd
        nixfmt-rfc-style
        # python
        python3
        (pkgs.writeShellScriptBin "basedpyright-langserver" ''
          export LANG='en_US.UTF-8'
          exec ${lib.getExe' pkgs.basedpyright "basedpyright-langserver"} "$@"
        '')
        ruff
        uv
        # rust
        cargo
        rustc
        clippy
        rustfmt
        rust-analyzer
        # toml
        taplo
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
