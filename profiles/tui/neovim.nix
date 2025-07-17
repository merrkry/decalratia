{
  config,
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
      home.packages = lib.singleton (
        # https://github.com/NixOS/nixpkgs/issues/281219#issuecomment-2284713258
        pkgs.buildFHSEnv {
          name = "nvim";
          targetPkgs =
            pkgs:
            (with pkgs; [
              gcc
              neovim
              unzip # `stylua: failed to install`
            ]);

          runScript = pkgs.writeShellScript "nvim" ''
            exec ${lib.getExe' pkgs.neovim "nvim"} "$@"
          '';
        }
      );
    };
  };
}
