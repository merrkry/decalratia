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

  # https://github.com/Supreeeme/xwayland-satellite/issues/252
  xwayland-satellite = helpers.overrideRustPlatformArgs pkgs "xwayland-satellite" {
    src = pkgs.fetchFromGitHub {
      owner = "Supreeeme";
      repo = "xwayland-satellite";
      rev = "f379ff5722a821212eb59ada9cf8e51cb3654aad";
      hash = "sha256-ceYEV6PnvUN8Zixao4gpPuN+VT3B0SlAXKuPNHZhqUY=";
    };
    cargoHash = "sha256-QAzAD7N8kReX/O7FSoYfDagOCOBmqTCu98okeYPmhBo=";
  };
}
