{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.gnome-text-editor;
in
{
  options.profiles.gui.gnome-text-editor = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      dconf.settings."org/gnome/TextEditor" = {
        restore-session = false;
      };

      home.packages = [ pkgs.gnome-text-editor ];
    };
  };
}
