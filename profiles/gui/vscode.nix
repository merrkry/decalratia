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
        # TODO: figure out how to override vscode-fhs
        package = pkgs.vscode.override {
          commandLineArgs =
            lib.chromiumArgs
            # https://code.visualstudio.com/docs/editor/settings-sync#_troubleshooting-keychain-issues
            # gnome or gnome-keyring doesn't work
            ++ [ "--password-store=gnome-libsecret" ];
        };
      };

      stylix.targets.vscode.enable = false;

    };

  };
}
