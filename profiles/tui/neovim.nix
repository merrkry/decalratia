{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.neovim;
in
{
  options.profiles.tui.neovim = {
    enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = with pkgs; [
        inputs.neovim-nightly-overlay.packages.${config.nixpkgs.system}.default

        tree-sitter
        unzip # stylua
      ];

      # clangd etc. installed from non-nixpkgs cannot find standard libraries even in fhsenv
      # home.packages = lib.singleton (
      #   # https://github.com/NixOS/nixpkgs/issues/281219#issuecomment-2284713258
      #   pkgs.buildFHSEnv {
      #     name = "nvim";
      #     targetPkgs =
      #       pkgs:
      #       (with pkgs; [
      #         gcc
      #         glibc
      #         neovim
      #         tree-sitter
      #         unzip # `stylua: failed to install`
      #       ]);
      #
      #     runScript = pkgs.writeShellScript "nvim" ''
      #       exec ${lib.getExe' pkgs.neovim "nvim"} "$@"
      #     '';
      #   }
      # );
    };
  };
}
