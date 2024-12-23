{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.lunarvim;
in
{
  options.profiles.cli.lunarvim = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [ lunarvim ];

    };

  };

}
