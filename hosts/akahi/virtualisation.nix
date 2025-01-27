{
  config,
  lib,
  pkgs,
  ...
}:
{
  specialisation = {
    "vfio".configuration =
      let
        config' = config.specialisation."vfio".configuration;
      in
      {
        boot = {
          extraModprobeConfig = ''
            softdep nvidia pre: vfio-pci
            options vfio-pci ids=10de:249d,10de:228b
            options kvmfr static_size_mb=128
            options kvm ignore_msrs=1 report_ignored_msrs=0 halt_poll_ns=0
            options vfio-iommu-type1 allow_unsafe_interrupts=Y
          '';
          extraModulePackages = with config'.boot.kernelPackages; [ kvmfr ];
          kernelModules = [ "kvmfr" ]; # vfio will be loaded by libvirt
          # Maintain an out-of-tree module to compile on latest kernel is such a pain in the ass
          # It's more wise to pin on latest LTS
          kernelPackages = pkgs.linuxPackages;
          kernelParams = [ "intel_iommu=on" ];
        };

        environment.systemPackages = with pkgs; [ looking-glass-client-git ];

        # systemd.tmpfiles.rules = [
        #   "f /dev/shm/looking-glass 0660 root kvm -"
        # ];
        services.udev.extraRules = ''
          SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
        '';

        virtualisation.libvirtd.qemu.verbatimConfig = ''
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom", "/dev/ptmx",
            "/dev/kvm", "/dev/rtc", "/dev/hpet",
            "/dev/kvmfr0"
          ]
        '';
      };
  };

  virtualisation = {
    podman.autoPrune.enable = false; # prevent distrobox images from being deleted

    libvirtd = {
      enable = true;
      qemu = {
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        swtpm.enable = true;
      };

      hooks.qemu = {
        # TODO: add module to configure hook like this:
        # "win-vfio".prepare.begin = "${lib.getExe switch-vfio} bind";
        # "win-vfio".release.end = "${lib.getExe switch-vfio} unbind";
        "vfio" =
          let
            hugePages = 16 * 1024 / 2;
          in
          lib.getExe (
            pkgs.writeShellScriptBin "libvirt-hook-vfio" ''
              VM_ISOLATED_CPUS=0-1,12-19
              SYS_TOTAL_CPUS=0-19

              if [ "$1" == "win-vfio" ]; then
                if [ "$2" == "prepare" ]; then

                    echo 3 > /proc/sys/vm/drop_caches
                    echo 1 > /proc/sys/vm/compact_memory

                    sleep 3

                    ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
                    HUGEPAGES=${toString hugePages}
                    TRIES=0
                    while (( $ALLOC_PAGES != $HUGEPAGES && $TRIES < 10 ))
                    do
                        echo 1 > /proc/sys/vm/compact_memory
                        echo $HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
                        ALLOC_PAGES=$(cat /proc/sys/vm/nr_hugepages)
                        let TRIES+=1
                    done
                    if [ "$ALLOC_PAGES" -ne "$HUGEPAGES" ]
                    then
                        echo 0 > /proc/sys/vm/nr_hugepages
                        exit 1
                    fi

                    systemctl set-property --runtime -- user.slice AllowedCPUs=$VM_ISOLATED_CPUS
                    systemctl set-property --runtime -- system.slice AllowedCPUs=$VM_ISOLATED_CPUS
                    systemctl set-property --runtime -- init.scope AllowedCPUs=$VM_ISOLATED_CPUS

                elif [ "$2" == "release" ]; then

                    echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

                    systemctl set-property --runtime -- user.slice AllowedCPUs=$SYS_TOTAL_CPUS
                    systemctl set-property --runtime -- system.slice AllowedCPUs=$SYS_TOTAL_CPUS
                    systemctl set-property --runtime -- init.scope AllowedCPUs=$SYS_TOTAL_CPUS

                fi
              fi
            ''
          );
      };

      onShutdown = "shutdown";
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;
}
