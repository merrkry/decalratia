{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.zed;
in
{
  options.profiles.gui.zed = {
    enable = lib.mkEnableOption "zed";
    enableAI = lib.mkEnableOption "AI";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.zed-editor = {
        enable = true;
        package = pkgs.zed-editor.fhsWithPackages (pkgs: (with pkgs; [ openssl ]));
      };

      # stylix.targets.zed.enable = true;
    };
  };
}
