{ lib, modulesPath, ... }:
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
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems =
    let
      mkBtrfsMountPoint = subvol: {
        device = "/dev/disk/by-uuid/1c6dc525-c4d7-4f77-8d11-d5b7cd765ad1";
        fsType = "btrfs";
        options = [ "subvol=${subvol}" ] ++ lib.recommendedBtrfsArgs;
      };
    in
    {
      "/" = mkBtrfsMountPoint "@persist";
      "/boot" = {
        device = "/dev/disk/by-uuid/F861-44AC";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
      "/nix" = mkBtrfsMountPoint "@nix";
      # # nodatacow option can only apply on all subvols of the entire fs, use chattr instead
      "/var/lib/postgresql" = mkBtrfsMountPoint "@psql";
    };

  services.qemuGuest.enable = true;

  swapDevices = [ { device = "/dev/disk/by-uuid/974968c5-3d87-4b6b-9b3a-5b91ebd072e9"; } ];
}
