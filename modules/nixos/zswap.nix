{ config, lib, ... }:
let
  cfg = config.zswap;
in
{
  options.zswap = {

    enable = lib.mkOption {
      default = !config.zramSwap.enable;
      type = lib.types.bool;
      description = ''
        https://docs.kernel.org/admin-guide/mm/zswap.html
        https://wiki.archlinux.org/title/Zswap
      '';
    };

    shrinker = lib.mkOption {
      default = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8";
      type = lib.types.bool;
      description = ''
        Requires kernel 6.8.0+.
        When there is a sizable amount of cold memory residing in the zswap pool,
        it can be advantageous to proactively write these cold pages to swap,
        and reclaim the memory for other use cases.
      '';
    };

    max-pool-percent = lib.mkOption {
      default = 40;
      type = lib.types.int;
    };

    compressor = lib.mkOption {
      default = "zstd";
      type =
        with lib.types;
        either (enum [
          "lzo"
          "lz4"
          "zstd"
        ]) str;
    };

    zpool = lib.mkOption {
      default = "zsmalloc";
      type =
        with lib.types;
        either (enum [
          "zbud"
          "zsmalloc"
        ]) str;
    };

    accept-threshold-percent = lib.mkOption {
      default = 90;
      type = lib.types.int;
    };
    description = ''
      To prevent zswap from shrinking pool when zswap is full and there's a high pressure on swap
      (this will result in flipping pages in and out zswap pool,
      without any real benefit but with a performance drop for the system),
      a special parameter has been introduced to implement a sort of hysteresis ,
      to refuse taking pages into zswap pool until it has sufficient space if the limit has been hit.
    '';
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules =
      [
        "w- /sys/module/zswap/parameters/enabled - - - - 1"
        "w- /sys/module/zswap/parameters/max_pool_percent - - - - ${toString cfg.max-pool-percent}"
        "w- /sys/module/zswap/parameters/compressor - - - - ${cfg.compressor}"
        "w- /sys/module/zswap/parameters/zpool - - - - ${cfg.zpool}"
        "w- /sys/module/zswap/parameters/accept_threshold_percent - - - - ${toString cfg.accept-threshold-percent}"
      ]
      ++ (lib.optional (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8") "w- /sys/module/zswap/parameters/shrinker_enabled - - - - ${
        if cfg.shrinker then "Y" else "N"
      }");
  };
}
