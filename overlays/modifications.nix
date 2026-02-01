{
  helpers,
  pkgs,
  ...
}:
let
  # Use system file chooser provided by xdg portal instead of bundled ugly qt file chooser
  useQGtk3StyleArgs = [
    "--prefix"
    "QT_QPA_PLATFORMTHEME"
    ":"
    "gtk3"
  ];
in
{
  materialgram = pkgs.materialgram.overrideAttrs (
    final: prev: {
      qtWrapperArgs = prev.qtWrapperArgs ++ useQGtk3StyleArgs;
    }
  );

  prismlauncher = pkgs.prismlauncher.override { jdks = [ pkgs.emptyDirectory ]; };
}
