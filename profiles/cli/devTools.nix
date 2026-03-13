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
      home = {
        # Life is much easier when managed by a more imperative package manager, e.g. mise.
        # We use Nix when:
        # - No packaging available in aqua or language toolchain.
        # - No prebuilt binaries available and build can be tricky.
        # - Only Nixpkgs version works on NixOS. (C++)
        # - We want it to be available as early as possible.
        packages = with pkgs; [
          # Universal tools
          gnumake
          mesonlsp
          typos-lsp
          # Language toolchains
          # If one tool of a language must be installed via Nix,
          # we also install the rest of them via Nix for ease of administration.
          ## bash
          bash-language-server
          shfmt # used by bash-language-server automatically
          ## c / cpp
          gcc
          clang-tools
          cmake
          ## kdl
          kdlfmt
          ## latex
          texlab
          tex-fmt
          ## lua
          luajit
          emmylua-ls
          stylua
          ## nix
          nixd
          nixfmt
          statix
        ];

        sessionVariables = {
          OPENCODE_DISABLE_LSP_DOWNLOAD = "true";
        };
      };
    };
  };
}
