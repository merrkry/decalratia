{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  services.qemuGuest.enable = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems =
    let
      mkBtrfsMountPoint = subvol: {
        device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
        fsType = "btrfs";
        options = [
          "subvol=${subvol}"
          "noatime"
          "compress=zstd"
        ];
      };
    in
    {
      "/" = mkBtrfsMountPoint "persist";
      "/boot" = {
        device = "/dev/disk/by-uuid/f72516c4-a39f-4330-a877-1d73ad6aaa66";
        fsType = "ext4";
      };
      "home" = mkBtrfsMountPoint "home";
      "/nix" = mkBtrfsMountPoint "nix";
    };

  # TODO: switch to swapfile
  zramSwap.enable = true;
}
