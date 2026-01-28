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

  niri = helpers.overrideRustPlatformArgs pkgs "niri" {
    src = pkgs.fetchFromGitHub {
      owner = "YaLTeR";
      repo = "niri";
      rev = "b5640d5293ad8dca06cb447692ea7cbb21680eb1";
      hash = "sha256-83/YSW6c58i/iwGzAFApuMy6MCgoIaROeCcoIGh+ViU=";
    };
    cargoHash = "sha256-Fd84E3XK8+ODlY4JUbgnSrNtQReqVAT2aTnCt8vE+oI=";
  };

  prismlauncher = pkgs.prismlauncher.override { jdks = [ pkgs.emptyDirectory ]; };
}
