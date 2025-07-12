{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.lunarvim;
in
{
  options.profiles.tui.lunarvim = {
    enable = lib.mkEnableOption "lunarvim";
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [ lunarvim ];

    };

  };

}
