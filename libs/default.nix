{ lib, ... }:
rec {
  mkModulesList =
    path:
    (lib.pipe path [
      builtins.readDir
      (lib.mapAttrsToList (
        name: value:
        (
          if
            (value == "regular" && lib.hasSuffix ".nix" name && name != "default.nix") || (value == "directory")
          then
            name
          else
            null
        )
      ))
      (lib.filter (x: x != null))
      (lib.map (fileName: path + "/${fileName}"))
    ]);

  mkEnableOption' =
    {
      default ? false,
    }:
    lib.mkOption {
      inherit default;
      type = lib.types.bool;
      visible = false;
    };

  ChromiumArgs = builtins.foldl' (x: y: x + " " + y) "" [
    "--ozone-platform-hint=auto"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
    "--password-store=gnome-libsecret"
  ];
}
