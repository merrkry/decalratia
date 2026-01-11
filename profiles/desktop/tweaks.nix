{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop.tweaks;
  hasCachyPatchset = (builtins.match ".*cachyos.*" config.boot.kernelPackages.kernel.name) != null;
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
        "scx_cosmos"
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

          # TODO: switch to LTS kernel when it defaults to 6.18
          kernelPackages =
            let
              kernel =
                inputs.cachyos-kernel.legacyPackages.${config.nixpkgs.system}.linux-cachyos-latest.override
                  {
                    preemptType = "lazy";
                    bbr3 = true;
                    processorOpt = "x86_64-v3";
                  };
            in
            pkgs.linuxKernel.packagesFor kernel;

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

        # https://wiki.cachyos.org/configuration/general_system_tweaks/#adios-io-scheduler
        services.udev.extraRules =
          let
            hddSched = "bfq";
            ssdSched = if hasCachyPatchset then "adios" else "mq-deadline";
            nvmeSched = if hasCachyPatchset then "adios" else "none";
          in
          ''
            ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="${hddSched}"
            ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${ssdSched}"
            ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="${nvmeSched}"
          '';

        systemd = {
          oomd.enable = true; # kills services e.g. xremap even when ram is sufficient during suspension and wakups
          tmpfiles.rules = [ "d /var/lib/systemd/coredump 0755 root root 7d" ];
        };
      }
      (lib.mkIf (cfg.scheduler == "eevdf") {
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
          # https://github.com/CachyOS/ananicy-rules/blob/master/ananicy.conf
          settings = lib.mkMerge [
            {
              cgroup_realtime_workaround = lib.mkForce false;
              check_freq = 15;
            }
            # Requires kernel patch
            # FIXME: log reported it is still disabled
            (lib.mkIf hasCachyPatchset {
              apply_latnice = true;
            })
          ];
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
          inherit (cfg) scheduler;
        };
      })
    ]
  );
}
