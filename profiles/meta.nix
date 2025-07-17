{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.meta;
  levelNums = {
    "base" = 0;
    "base-devel" = 1;
    "desktop" = 2;
  };
  levelNum = levelNums.${cfg.type};
in
{
  options.profiles.meta = {
    type = lib.mkOption {
      type = lib.types.enum [
        "base"
        "base-devel"
        "desktop"
      ];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (levelNum >= levelNums."base") {
      profiles.base = {
        enable = true;
      };
    })

    (lib.mkIf (levelNum >= levelNums."base-devel") {
      profiles.base-devel = {
        enable = true;
      };
    })

    (lib.mkIf (levelNum >= levelNums."desktop") {
      profiles.desktop = {
        enable = true;
      };
    })
  ];
}
