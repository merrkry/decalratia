{
  config,
  lib,
  pkgs,
  ...
}:
let
  dgpu = {
    bus = "0000:01:00.0";
    info = "10de 249d";
  };
  # libvirt can handle snd_hda_intel automatically
  # audio = {
  #   bus = "0000:01:00.1";
  #   info = "10de 228b";
  # };

  # modeset and fbdev is now enabled by default
  # other options for nvidia drivers are defined in boot.extraModprobeConfig
  switch-vfio = pkgs.writeShellScriptBin "switch-vfio" ''
    if [[ $(whoami) != "root" ]]; then
        exit 1
    fi

    get_vd() {
        return "$(cat /sys/bus/pci/devices/$1/vendor) $(cat /sys/bus/pci/devices/$1/device)"
    }

    services=("nvidia-container-toolkit-cdi-generator.service" "nvidia-persistenced.service" "nvidia-powerd")

    if [ "$1" == "bind" ]; then

        for service in "''${services[@]}"; do
            systemctl stop "$service"
        done
        # sometimes it will stuck here
        echo "${dgpu.bus}" > /sys/bus/pci/devices/${dgpu.bus}/driver/unbind &>/dev/null
        rmmod nvidia_uvm
        rmmod nvidia_drm
        rmmod nvidia_modeset
        rmmod nvidia
        modprobe vfio
        modprobe vfio_pci_core
        modprobe vfio_pci
        modprobe vfio_iommu_type1
        echo "${dgpu.info}" > /sys/bus/pci/drivers/vfio-pci/new_id

    elif [ "$1" == "unbind" ]; then

        echo "${dgpu.info}" > /sys/bus/pci/drivers/vfio-pci/remove_id
        rmmod vfio_iommu_type1
        rmmod vfio_pci
        rmmod vfio_pci_core
        rmmod vfio
        echo "1" > /sys/bus/pci/devices/${dgpu.bus}/remove
        echo 1 > /sys/bus/pci/rescan
        for service in "''${services[@]}"; do
            systemctl start "$service"
        done

    fi
  '';
in
{
  virtualisation = {
    containers = {
      enable = true;
      storage.settings = {
        storage = {
          driver = "btrfs";
          graphroot = "/var/lib/containers/storage";
          runroot = "/run/containers/storage";
        };
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      # Runs `podman system prune -f` periodically, will delete stopped distrobox container
      autoPrune.enable = false;
    };

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

                    ${lib.getExe switch-vfio} bind

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

                    ${lib.getExe switch-vfio} unbind

                    echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages

                    systemctl set-property --runtime -- user.slice AllowedCPUs=$SYS_TOTAL_CPUS
                    systemctl set-property --runtime -- system.slice AllowedCPUs=$SYS_TOTAL_CPUS
                    systemctl set-property --runtime -- init.scope AllowedCPUs=$SYS_TOTAL_CPUS
                fi
              fi
            ''
          );
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  boot.kernelParams = [ "intel_iommu=on" ];

  environment.systemPackages = [ switch-vfio ];

  boot = {
    kernelModules = [ "kvmfr" ];
    extraModulePackages = with config.boot.kernelPackages; [ kvmfr ];
    extraModprobeConfig = ''
      options kvmfr static_size_mb=128
      options kvm ignore_msrs=1 report_ignored_msrs=0 halt_poll_ns=0
      options vfio-iommu-type1 allow_unsafe_interrupts=Y
    '';
  };

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
}
