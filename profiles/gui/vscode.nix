{
  config,
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
      # Extensions managed by scripts.
      home.packages = with pkgs; [
        vscode
      ];
    };
  };
}
