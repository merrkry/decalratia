{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.mime;
in
{
  options.profiles.desktop.mime = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [
        foliate
        evince
        eog
      ];

      xdg.mimeApps =
        let
          browser = [
            "firefox.desktop"
            "chromium-browser.desktop"
          ];
        in
        {
          enable = true;
          defaultApplications = lib.mkMerge [
            {
              "application/pdf" = [ "org.gnome.Evince.desktop" ];
              "application/epub+zip" = [ "com.github.johnfactotum.Foliate.desktop" ];
              "x-scheme-handler/http" = browser;
              "x-scheme-handler/https" = browser;

              "x-scheme-handler/obsidian" = [ "md.obsidian.Obsidian.desktop" ];
              "x-scheme-handler/tg" = [ "io.github.kukuruzka165.materialgram.desktop" ];

              # wildcard is not supported
              # https://gitlab.freedesktop.org/xdg/xdgmime/-/issues/16
              # "audio/*" = [ "mpv.desktop" ];
              # "video/*" = [ "mpv.desktop" ];
              #  "image/*" = [ "org.gnome.eog.desktop" ];
            }
            (
              let
                genMimeList =
                  type: formatList: defaultAppList:
                  (builtins.listToAttrs (
                    map (x: {
                      name = "${type}/${x}";
                      value = defaultAppList;
                    }) formatList
                  ));

                # genTypedMimeList = genMimeList ""; # `image/` etc. should be included in the list

                # copied from org.gnome.eog.desktop
                imageTypeList = [
                  "bmp"
                  "gif"
                  "jpeg"
                  "jpg"
                  "jxl"
                  "pjpeg"
                  "png"
                  "tiff"
                  "webp"
                  "x-bmp"
                  "x-gray"
                  "x-icb"
                  "x-ico"
                  "x-png"
                  "x-portable-anymap"
                  "x-portable-bitmap"
                  "x-portable-graymap"
                  "x-portable-pixmap"
                  "x-xbitmap"
                  "x-xpixmap"
                  "x-pcx"
                  "svg+xml"
                  "svg+xml-compressed"
                  "vnd.wap.wbmp"
                  "x-icns"
                ];
              in
              (genMimeList "image" imageTypeList [ "org.gnome.eog.desktop" ])
            )
          ];
        };

    };

  };
}
