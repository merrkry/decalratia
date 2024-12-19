{ config, lib, ... }:
let
  cfg = config.profiles.desktop.tweaks;
in
{
  options.profiles.desktop.tweaks = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    boot = {
      kernel.sysctl = {
        "kernel.panic" = 10;
        "kernel.sched_cfs_bandwidth_slice_us" = 3000;
        "kernel.split_lock_mitigate" = 0;
        "kernel.sysrq" = 1;
        "vm.max_map_count" = 2147483642;
      };

      kernelParams = [
        "preempt=full"
        "split_lock_detect=off"
      ];
    };

    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
    '';

  };
}
