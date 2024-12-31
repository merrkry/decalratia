{ ... }:
{

  boot = {
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
        "virtio_blk"
      ];
    };
    kernelModules = [ "kvm-intel" ];
  };

  disko.devices = {
    disk = {
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
                subvolumes =
                  let
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  in
                  {
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
                      swap.swapfile.size = "2G";
                    };
                  };
              };
            };
          };
        };
      };
    };
  };

  services.qemuGuest.enable = true;

}
