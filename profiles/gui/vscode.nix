{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.vscode;
in
{
  options.profiles.gui.vscode = {
    enable = lib.mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = with pkgs; [
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            asvetliakov.vscode-neovim
            emroussel.atomize-atom-one-dark-theme
            github.copilot
            github.copilot-chat
            golang.go
            jnoortheen.nix-ide
            myriad-dreamin.tinymist
            rust-lang.rust-analyzer
          ];
        })
      ];
    };
  };
}
