{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
    };
  };

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

            genTypedMimeList =
              formatList: defaultAppList:
              (builtins.listToAttrs (
                map (x: {
                  name = "${x}";
                  value = defaultAppList;
                }) formatList
              ));

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

            # copied from org.kde.ark.desktop
            archiveTypeList = [
              "application/x-deb"
              "application/x-cd-image"
              "application/x-bcpio"
              "application/x-cpio"
              "application/x-cpio-compressed"
              "application/x-sv4cpio"
              "application/x-sv4crc"
              "application/x-rpm"
              "application/x-compress"
              "application/gzip"
              "application/x-bzip"
              "application/x-bzip2"
              "application/x-lzma"
              "application/x-xz"
              "application/zlib"
              "application/zstd"
              "application/x-lz4"
              "application/x-lzip"
              "application/x-lrzip"
              "application/x-lzop"
              "application/x-source-rpm"
              "application/vnd.debian.binary-package"
              "application/vnd.efi.iso"
              "application/vnd.ms-cab-compressed"
              "application/x-xar"
              "application/x-iso9660-appimage"
              "application/x-archive"
              "application/x-tar"
              "application/x-compressed-tar"
              "application/x-bzip-compressed-tar"
              "application/x-bzip2-compressed-tar"
              "application/x-tarz"
              "application/x-xz-compressed-tar"
              "application/x-lzma-compressed-tar"
              "application/x-lzip-compressed-tar"
              "application/x-tzo"
              "application/x-lrzip-compressed-tar"
              "application/x-lz4-compressed-tar"
              "application/x-zstd-compressed-tar"
              "application/x-7z-compressed"
              "application/vnd.rar"
              "application/zip"
              "application/x-java-archive"
              "application/x-lha"
              "application/x-stuffit"
              "application/x-arj"
              "application/arj"
            ];
          in
          (genMimeList "image" imageTypeList [ "org.gnome.eog.desktop" ])
          // (genTypedMimeList archiveTypeList [ "org.kde.ark.desktop" ])
        )
      ];
    };
}
