{
  config,
  inputs,
  helpers,
  lib,
  modulesPath,
  options,
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
      luks = {
        devices.${luksDevice}.device = "/dev/disk/by-uuid/285de22c-80b3-48fe-a0ff-3cc384c31aaa";
        # https://github.com/NixOS/nixpkgs/issues/501777
        cryptoModules =
          let
            defaultModules = options.boot.initrd.luks.cryptoModules.default;
            deprecated = lib.optionals (lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.0") [
              "aes_generic"
            ];
          in
          lib.subtractLists deprecated defaultModules;
      };
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
    kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
    kernelParams = [
      # Seems fixed in Linux 7.0
      # https://gitlab.freedesktop.org/drm/xe/kernel/-/issues/7284
      # "xe.enable_psr=0"
      # "xe.enable_panel_replay=0"
    ];
  };

  # TODO: remove with libinput 1.31
  # ref: https://www.bilibili.com/read/cv42222859
  # upstream: https://gitlab.freedesktop.org/libinput/libinput/-/commit/a525b3032681691b7d86bde2f9dd66525071af95
  # `lib.generators.toINI` might mess up attribute order, we use string literals instead.
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Lenovo ThinkBook G8+ IPH touchpad]
    MatchName=*GXTP5100*
    MatchDMIModalias=dmi:*svnLENOVO:*pvrThinkBook*G8+IPH*:*
    MatchUdevType=touchpad
    ModelPressurePad=1
  '';

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

    intel-lpmd.enable = true;
    thermald.enable = true;

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
