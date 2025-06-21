{ pkgs, ... }:
{
  # TODO: remove this when waybar 0.12.0+ releases
  # https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/issues/4037
  waybar = pkgs.waybar.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [
      (pkgs.fetchpatch {
        url = "https://patch-diff.githubusercontent.com/raw/Alexays/Waybar/pull/4102.patch";
        hash = "sha256-toW3TonaQJWJhCkt4vHi0QUXVo87eLfmOZ8FUDMtMhE=";
      })
    ];
  });
}
