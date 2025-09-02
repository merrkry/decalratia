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
    enable = lib.mkEnableOption "tweaks" // {
      default = config.profiles.desktop.enable;
    };
    powersave = lib.mkEnableOption "powersave" // {
      default = config.services.tlp.enable;
    };
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
            "kernel.sysrq" = 244; # REISUB only
            "vm.max_map_count" = 2147483642;
            "vm.vfs_cache_pressure" = 50;
            "vm.dirty_bytes" = 268435456;
            "vm.dirty_background_bytes" = 67108864;
            "vm.dirty_writeback_centisecs" = 1500;
            "vm.watermark_boost_factor" = 0;
            "vm.watermark_scale_factor" = 125;
          }
          // (
            if config.zramSwap.enable then
              {
                "vm.swappiness" = 180;
                "vm.page-cluster" = 0;
              }
            else
              {
                "vm.swappiness" = 10;
                "vm.page-cluster" = 1;
              }
          );

          kernelPackages = lib.mkDefault pkgs.linuxPackages_zen;

          kernelParams = [
            "split_lock_detect=off"
          ]
          ++ (
            if (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.13") then
              [ "preempt=lazy" ]
            else
              [ "preempt=full" ]
          )
          ++ (lib.optionals cfg.powersave [ "rcutree.enable_rcu_lazy=1" ]); # https://wiki.cachyos.org/configuration/general_system_tweaks
        };

        services.udev.extraRules = ''
          ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
          ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
        '';

        systemd = {
          oomd.enable = true; # kills services e.g. xremap even when ram is sufficient during suspension and wakups
          tmpfiles.rules = [ "d /var/lib/systemd/coredump 0755 root root 7d" ];
        };
      }
      # use if-then-else here will cause infinite recursion
      (lib.mkIf (cfg.scheduler == "eevdf") {
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
          settings = {
            # apply_latnice requires a kernel patch that's even not included in cachyos's latest kernel patchset.
            # Perhaps it's a packaging issue in chaotic-nyx side but it is certain that the rules cannot work as expected as they are on CachyOS.
            # apply_latnice = true;
            check_freq = 15;
            # may introduce issues, for example with polkit, according to https://github.com/CachyOS/ananicy-rules/blob/master/ananicy.conf
            cgroup_realtime_workaround = lib.mkForce false;
          };
          extraRules = [
            {
              name = "AI-LIMIT.exe";
              type = "Game";
            }
          ];
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
