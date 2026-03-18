{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.thunderbird;
in
{
  options.profiles.gui.thunderbird = {
    enable = lib.mkEnableOption "thunderbird";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.thunderbird = {
        enable = true;
        package = pkgs.thunderbird-latest;
        profiles = { };
      };

      # https://bugzilla.mozilla.org/show_bug.cgi?id=2007074
      systemd.user.tmpfiles.rules = [
        "R %h/Thunderbird - - - - -"
      ];
    };
  };
}
