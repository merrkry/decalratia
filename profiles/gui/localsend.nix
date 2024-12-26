{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.localsend;
in
{
  options.profiles.gui.localsend = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    programs.localsend = {
      enable = true;
      openFirewall = true;
    };

    home-manager.users.${user} = {

    };

  };
}
