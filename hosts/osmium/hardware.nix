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
      "xe.enable_psr=0"
      "xe.enable_panel_replay=0"
    ];
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

  swapDevices = [ ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    intelgpu.vaapiDriver = "intel-media-driver";
  };
}
