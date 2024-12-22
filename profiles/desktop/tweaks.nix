{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop.tweaks;
in
{
  options.profiles.desktop.tweaks = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
    powersave = lib.mkEnableOption' { default = config.services.tlp.enable; };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot = {
          kernel.sysctl = {
            "kernel.panic" = 10;
            "kernel.sched_cfs_bandwidth_slice_us" = 3000;
            "kernel.split_lock_mitigate" = 0;
            "kernel.sysrq" = 1;
            "vm.max_map_count" = 2147483642;
            "vm.page-cluster" = if config.zramSwap.enable then 0 else 1;
          };

          kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

          kernelParams = [
            "preempt=full"
            "split_lock_detect=off"
          ] ++ (lib.optionals cfg.powersave [ "rcutree.enable_rcu_lazy=1" ]); # https://wiki.cachyos.org/configuration/general_system_tweaks;
        };

        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
          ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
        '';
      }
      (lib.mkIf (cfg.powersave && (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.12")) {
        services.scx = {
          enable = true;
          scheduler = "scx_lavd";
        };
      })
    ]
  );
}
