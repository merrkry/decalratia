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
    scheduler = lib.mkOption {
      type = lib.types.enum [
        "eevdf"
        "scx_bpfland"
        "scx_lavd"
      ];
      default = "eevdf";
    };
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
      # use if-then-else here will cause infinite recursion
      (lib.mkIf (cfg.scheduler == "eevdf") {
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
          settings = {
            # may introduce issues, for example with polkit, according to https://github.com/CachyOS/ananicy-rules/blob/master/ananicy.conf
            cgroup_realtime_workaround = lib.mkForce false;
          };
        };
      })
      (lib.mkIf (cfg.scheduler != "eevdf") {
        assertions = [
          {
            assertion = lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.12";
            message = "Kernel version 6.12+ is required for scx scheduler";
          }
        ];
        services.scx = {
          enable = true;
          scheduler = cfg.scheduler;
        };
      })
    ]
  );
}
