{ lib, modulesPath, ... }:
let
  mountOptions = lib.recommendedBtrfsArgs;
in
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    extraModulePackages = [ ];
    initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "sr_mod"
      "virtio_blk"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ ];
  };

  disko.devices.disk = {
    main = {
      device = "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          grub = {
            size = "1M";
            type = "EF02"; # for grub MBR
          };
          boot = {
            size = "512M";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/@rootfs" = {
                  inherit mountOptions;
                  mountpoint = "/";
                };
                "/@home" = {
                  inherit mountOptions;
                  mountpoint = "/home";
                };
                "/@nix" = {
                  inherit mountOptions;
                  mountpoint = "/nix";
                };
                "/@swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "32G";
                };
                "/@psql" = {
                  # per-subvol setting of nodatacow is not supported yet
                  # https://btrfs.readthedocs.io/en/latest/Administration.html
                  # mountOptions = [
                  #   "noatime"
                  #   "nodatacow"
                  # ];
                  inherit mountOptions;
                  mountpoint = "/var/lib/postgresql";
                };
              };
            };
          };
        };
      };
    };
  };

  profiles.base.backup.snapperConfigs = {
    "rootfs" = "/";
  };

  services.qemuGuest.enable = true;

  systemd.tmpfiles.rules = [ "h /var/lib/postgresql - - - - +C" ];
}
