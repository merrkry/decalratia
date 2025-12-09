{
  helpers,
  pkgs,
  ...
}:
{
  # Use system file chooser provided by xdg portal instead of bundled ugly qt file chooser
  materialgram = pkgs.materialgram.overrideAttrs (
    final: prev: {
      qtWrapperArgs = prev.qtWrapperArgs ++ [
        "--prefix"
        "QT_QPA_PLATFORMTHEME"
        ":"
        "gtk3"
      ];
    }
  );
}
