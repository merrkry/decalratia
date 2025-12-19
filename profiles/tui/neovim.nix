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
  hmConfig = config.home-manager.users.${user};
  neovim-nightly = inputs.neovim-nightly-overlay.packages.${config.nixpkgs.system}.default;
in
{
  options.profiles.tui.neovim = {
    enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home = {
        packages = with pkgs; [
          neovim-nightly

          tree-sitter
          unzip # stylua
        ];

        sessionVariables = {
          # EmmyLua
          VIMRUNTIME = "${neovim-nightly}/share/nvim/runtime";
        };
      };

      systemd.user.tmpfiles.rules = [
        "L+ ${hmConfig.xdg.configHome}/nvim - - - - ${hmConfig.home.homeDirectory}/Projects/declaratia/nvim"
      ];
    };
  };
}
