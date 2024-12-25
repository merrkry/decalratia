{ config, lib, ... }:
let
  cfg = config.profiles.base.backup;
in
{
  options.profiles.base.backup = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
    snapperConfigs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = lib.mergeAttrsList [
        (lib.optionalAttrs (config.fileSystems."/".fsType == "btrfs") { "rootfs" = "/"; })
        (lib.optionalAttrs (
          builtins.hasAttr "/home" config.fileSystems && config.fileSystems."/home".fsType == "btrfs"
        ) { "home" = "/home"; })
      ];
      example = {
        "persist" = "/persist";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    services.snapper =
      let
        mkSnapperConfig = subvolPath: {
          SUBVOLUME = subvolPath;

          ALLOW_GROUPS = [ "wheel" ];

          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;

          TIMELINE_LIMIT_HOURLY = 12;
          TIMELINE_LIMIT_DAILY = 7;
          TIMELINE_LIMIT_WEEKLY = 2;
          TIMELINE_LIMIT_MONTHLY = 0;
          TIMELINE_LIMIT_QUARTERLY = 0;
          TIMELINE_LIMIT_YEARLY = 0;
        };
      in
      {
        persistentTimer = true;
        configs = builtins.mapAttrs (
          configName: subvolPath: (mkSnapperConfig subvolPath)
        ) cfg.snapperConfigs;
      };

  };
}
