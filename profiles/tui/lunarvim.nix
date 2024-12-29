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
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [ lunarvim ];

    };

  };

}
