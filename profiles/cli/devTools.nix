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
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = with pkgs; [
        # universal
        gnumake
        meson
        ninja
        # bash
        bash-language-server
        shfmt # used by bash-language-server automatically
        # c / cpp
        gcc
        clang-tools
        # go
        go
        gopls
        # nix
        nixd
        nixfmt-rfc-style
        # python
        python3
        pyright
        ruff
        # toml
        taplo
        # yaml
        yaml-language-server
        # misc
        nodePackages.prettier
        vscode-langservers-extracted
      ];
    };
  };
}
