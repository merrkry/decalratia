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
    enable = lib.mkEnableOption' { };
    enableAI = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.vscode = {
        enable = true;
        # this will let home-manager manage ~/.config/Code/User/settings.json
        # enableUpdateCheck = lib.mkForce false;
        package = pkgs.vscode.override { commandLineArgs = lib.ChromiumArgs; };
      };

      stylix.targets.vscode.enable = false;

    };

  };
}
