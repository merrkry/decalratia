{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.tui.atuin;
in
{
  options.profiles.tui.atuin = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.atuin = {
        enable = true;
        daemon.enable = true;
        flags = [ "--disable-up-arrow" ];
        settings = {
          sync_address = "https://atuin.tsubasa.moe";
        };
      };
    };
  };
}
