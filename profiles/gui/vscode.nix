{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.vscode;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.gui.vscode = {
    enable = lib.mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = with pkgs; [
        (vscode-with-extensions.override {
          vscodeExtensions =
            (with vscode-extensions; [
              asvetliakov.vscode-neovim
              emroussel.atomize-atom-one-dark-theme
              github.copilot
              github.copilot-chat
              golang.go
              jnoortheen.nix-ide
              myriad-dreamin.tinymist
              rust-lang.rust-analyzer
            ])
            ++ (with inputs.nix-vscode-extensions.extensions.${config.nixpkgs.system}.vscode-marketplace; [
              johnnymorganz.stylua
              tangzx.emmylua
            ]);
        })
      ];

      xdg.configFile."vscode-neovim".source =
        hmConfig.lib.file.mkOutOfStoreSymlink "${hmConfig.home.homeDirectory}/Projects/declaratia/nvim";
    };
  };
}
