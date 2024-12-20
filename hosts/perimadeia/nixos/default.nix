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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  services.rootfs-cleanup = {
    enable = true;
    uuid = "df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    rootfsSubvol = "root";
    backupSubvol = "root-old";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/f72516c4-a39f-4330-a877-1d73ad6aaa66";
    fsType = "ext4";
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    neededForBoot = true;
    fsType = "btrfs";
    options = [
      "subvol=persist"
      "noatime"
      "compress=zstd"
    ];
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var"
      "/etc/nixos"
      "/root"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    fsType = "btrfs";
    options = [
      "subvol=home"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/df9cc6a2-5479-4ce8-a857-29e4aa67ca8d";
    fsType = "btrfs";
    options = [
      "subvol=docker"
      "noatime"
      "compress=zstd"
    ];
  };

  zramSwap.enable = true;
}
