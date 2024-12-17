{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ce17b7f2-eb3c-4be4-bee2-f76e80feaffd";
    fsType = "btrfs";
    options = [
      "subvol=@persist"
      "noatime"
      "compress=zstd"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7745-B1D5";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/ce17b7f2-eb3c-4be4-bee2-f76e80feaffd";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "noatime"
      "compress=zstd"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/0a0168fe-f43d-4fca-b979-b8312747868a"; } ];

  networking.hostName = "karanohako";
  networking.useNetworkd = true;

  services.resolved.enable = true;

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig = {
      DHCP = "ipv4";
      IPv6AcceptRA = true; # SLAAC for IPv6
    };
    dhcpV4Config = {
      UseDNS = true;
    };
    # make routing on this interface a dependency for network-online.target
    linkConfig.RequiredForOnline = "routable";
  };

  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
