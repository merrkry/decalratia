{
  config,
  helpers,
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
      programs.vscode = {
        enable = true;
        # this will let home-manager manage ~/.config/Code/User/settings.json
        # enableUpdateCheck = lib.mkForce false;
        package =
          (pkgs.vscode.override {
            commandLineArgs =
              helpers.chromiumArgs
              # https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
              # gnome or gnome-keyring doesn't work
              ++ [ "--password-store=gnome-libsecret" ];
          }).fhs;
      };

      stylix.targets.vscode.enable = false;
    };
  };
}
