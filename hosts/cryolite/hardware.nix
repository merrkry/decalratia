{
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ ];
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "fido2-device=auto" ];
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/@rootfs" = {
                      mountpoint = "/";
                      mountOptions = lib.recommendedBtrfsArgs;
                    };
                    "/@home" = {
                      mountpoint = "/home";
                      mountOptions = lib.recommendedBtrfsArgs;
                    };
                    "/@nix" = {
                      mountpoint = "/nix";
                      mountOptions = lib.recommendedBtrfsArgs;
                    };
                    "/@swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  services.tlp = {
    enable = true;
    settings = {
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      PCIE_ASPM_ON_BAT = "powersupersave";
    };
  };
}
