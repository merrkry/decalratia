{
  inputs,
  helpers,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  luksDevice = "cryptroot";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "nvme"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "thunderbolt"
        "uas"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ ];
      luks.devices.${luksDevice}.device = "/dev/disk/by-uuid/285de22c-80b3-48fe-a0ff-3cc384c31aaa";
    };
    # lanzaboote = {
    #   enable = true;
    #   pkiBundle = "/var/lib/sbctl";
    # };
    loader = {
      # systemd-boot.enable = lib.mkForce false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      # TODO: try remove with Linux 7.0
      # https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/7284
      "xe.enable_psr=0"
      "xe.enable_panel_replay=0"
    ];
  };

  # TODO: remove with libinput 1.31
  # https://www.bilibili.com/read/cv42222859
  environment.etc."libinput/local-overrides.quirks".text = lib.generators.toINI { } {
    "Lenovo ThinkBook 16 G8+ IPH Touchpad" = {
      MatchName = "*GXTP5100*";
      MatchDMIModalias = "dmi:bvnLENOVO:bvrSWCN15WW:bd12/17/2025:br1.15:efr1.15:svnLENOVO:pn21VG:pvrThinkBook14G8+IPH:rvnLENOVO:rnLNVNB161216:rvrSDK0T76577WIN:cvnLENOVO:ct10:cvrThinkBook14G8+IPH:skuLENOVO_MT_21VG_BU_idea_FM_ThinkBook14G8+IPH:";
      MatchUdevType = "touchpad";
      ModelPressurePad = 1;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/${luksDevice}";
      fsType = "btrfs";
      options = [ "subvol=@rootfs" ] ++ helpers.recommendedBtrfsArgs;
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/20E5-840D";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };

    "/home" = {
      device = "/dev/mapper/${luksDevice}";
      fsType = "btrfs";
      options = [ "subvol=@home" ] ++ helpers.recommendedBtrfsArgs;
    };

    "/nix" = {
      device = "/dev/mapper/${luksDevice}";
      fsType = "btrfs";
      options = [ "subvol=@nix" ] ++ helpers.recommendedBtrfsArgs;
    };

    "/.swapvol" = {
      device = "/dev/mapper/${luksDevice}";
      fsType = "btrfs";
      options = [ "subvol=@swap" ];
    };
  };

  services = {
    fprintd.enable = true;

    tlp = {
      enable = true;
      pd.enable = true;
      settings = {
        # PD API reports `performance` on AC, and `balance` on BAT.
        # But `/sys/firmware/acpi/platform_profile` is actually set as expected.
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };

    upower.enable = true;
  };

  swapDevices = [ { device = "/.swapvol/swapfile"; } ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    intelgpu.vaapiDriver = "intel-media-driver";
  };
}
