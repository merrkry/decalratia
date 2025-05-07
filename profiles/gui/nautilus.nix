{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.nautilus;
in
{
  options.profiles.gui.nautilus = {
    enable = lib.mkEnableOption' { };
    useUpstreamPackage = lib.mkEnableOption { };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.nautilus ];

    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "foot";
    };

    services.gnome.sushi.enable = true;

    home-manager.users.${user} = {
      dconf.settings = {
        "org/gnome/nautilus/icon-view" = {
          captions = [
            "none"
            "none"
            "none"
          ];
        };
        "org/gnome/nautilus/list-view" = {
          default-zoom-level = "small";

          use-tree-view = true;
        };
        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "list-view";
          click-policy = "single";

          show-create-link = true;
          show-delete-permanently = true;

          recursive-search = "local-only";
          show-image-thumbnails = "local-only";
          show-directory-item-counts = "local-only";

          date-time-format = "simple";
        };

        "org/gtk/gtk4/settings/file-chooser" = {
          show-hidden = false;
          sort-directories-first = true;
        };
      };
    };
  };
}
