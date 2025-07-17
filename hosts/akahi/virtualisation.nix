{ pkgs, user, ... }:
{
  # specialisation = {
  #   "vfio".configuration =
  #     let
  #       config' = config.specialisation."vfio".configuration;
  #     in
  #     {
  #       boot = {
  #         extraModprobeConfig = ''
  #           softdep nvidia pre: vfio-pci
  #           options vfio-pci ids=10de:249d,10de:228b
  #           options kvmfr static_size_mb=128
  #           options kvm ignore_msrs=1 report_ignored_msrs=0 halt_poll_ns=0
  #           options vfio-iommu-type1 allow_unsafe_interrupts=Y
  #         '';
  #         extraModulePackages = with config'.boot.kernelPackages; [ kvmfr ];
  #         kernelModules = [ "kvmfr" ]; # vfio will be loaded by libvirt
  #         # Maintain an out-of-tree module to compile on latest kernel is such a pain in the ass
  #         # It's more wise to pin on latest LTS
  #         kernelPackages = pkgs.linuxPackages;
  #         kernelParams = [ "intel_iommu=on" ];
  #       };

  #       environment.systemPackages = with pkgs; [ looking-glass-client ];

  #       # systemd.tmpfiles.rules = [
  #       #   "f /dev/shm/looking-glass 0660 root kvm -"
  #       # ];
  #       services.udev.extraRules = ''
  #         SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
  #       '';

  #       virtualisation.libvirtd.qemu.verbatimConfig = ''
  #         namespaces = []
  #         cgroup_device_acl = [
  #           "/dev/null", "/dev/full", "/dev/zero",
  #           "/dev/random", "/dev/urandom", "/dev/ptmx",
  #           "/dev/kvm", "/dev/rtc", "/dev/hpet",
  #           "/dev/kvmfr0"
  #         ]
  #       '';
  #     };
  # };

  virtualisation = {
    podman.autoPrune.enable = false; # prevent distrobox images from being deleted

    libvirtd = {
      enable = true;
      qemu = {
        ovmf.packages = [ pkgs.OVMFFull.fd ];
        swtpm.enable = true;
      };

      onShutdown = "shutdown";
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  users.users.${user}.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
