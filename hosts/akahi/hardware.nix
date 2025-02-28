{ inputs, modulesPath, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 16;
        consoleMode = "auto";
        editor = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
  };

  fileSystems =
    let
      mkBtrfsMount = subvol: {
        device = "/dev/disk/by-uuid/ba21d45a-15fc-4af8-8793-b06ddb4407c5";
        fsType = "btrfs";
        options = [
          (if subvol != "" then "subvol=" + subvol else null)
          "noatime"
          "compress=zstd"
        ];
      };
    in
    {
      "/btrfs-root" = mkBtrfsMount "/";
      "/" = mkBtrfsMount "@nixos/@persist";
      "/nix" = mkBtrfsMount "@nixos/@nix";
      "/var/lib/libvirt/images" = mkBtrfsMount "@nixos/@images";
      "/boot" = {
        device = "/dev/disk/by-uuid/ECE8-D259";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
    };

  hardware = {
    cpu.intel.updateMicrocode = true;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  powerManagement.enable = true;

  services = {
    asusd = {
      enable = true;
      enableUserService = true;
    };
    power-profiles-daemon.enable = false;
    supergfxd.enable = false;
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        SOUND_POWER_SAVE_ON_AC = 0;
        SOUND_POWER_SAVE_ON_BAT = 10;

        START_CHARGE_THRESH_BAT = "60";
        STOP_CHARGE_THRESH_BAT1 = "80";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "quiet";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        CPU_MIN_PERF_ON_AC = "0";
        CPU_MAX_PERF_ON_AC = "100";
        CPU_MIN_PERF_ON_BAT = "0";
        CPU_MAX_PERF_ON_BAT = "40";

        CPU_BOOST_ON_AC = "1";
        CPU_BOOST_ON_BAT = "0";

        CPU_HWP_DYN_BOOST_ON_AC = "1";
        CPU_HWP_DYN_BOOST_ON_BAT = "0";

        RUNTIME_PM_ON_AC = "auto";

        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };
  };

  systemd = {
    tmpfiles.rules = [
      "w- /sys/devices/platform/asus-nb-wmi/nv_dynamic_boost - - - - 5"
      "w- /sys/devices/platform/asus-nb-wmi/nv_temp_target - - - - 87"
      "w- /sys/devices/platform/asus-nb-wmi/panel_od - - - - 0"
      "w- /sys/devices/platform/asus-nb-wmi/ppt_pl1_spl - - - - 45"
      "w- /sys/devices/platform/asus-nb-wmi/ppt_pl2_sppt - - - - 45"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/60005c5c-54dc-4ead-b28f-021d2f84c177"; }
    { device = "/dev/disk/by-uuid/6b2a6972-1f3c-45f3-a28a-ad2f215f9881"; }
  ];

}
