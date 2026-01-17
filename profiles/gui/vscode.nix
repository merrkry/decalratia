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
              charliermarsh.ruff
              emroussel.atomize-atom-one-dark-theme
              esbenp.prettier-vscode
              github.copilot-chat
              golang.go
              jnoortheen.nix-ide
              llvm-vs-code-extensions.vscode-clangd
              ms-python.python
              ms-toolsai.jupyter
              ms-toolsai.jupyter-renderers
              myriad-dreamin.tinymist
              rust-lang.rust-analyzer
              tamasfe.even-better-toml
              tekumara.typos-vscode
            ])
            ++ (with inputs.vscode-extensions.extensions.${config.nixpkgs.system}.vscode-marketplace; [
              johnnymorganz.stylua
              meta.pyrefly
              tangzx.emmylua
            ]);
        })
      ];
    };
  };
}
