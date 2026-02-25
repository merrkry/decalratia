{ helpers, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot = {
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelModules = [ "kvm-intel" ];
  };

  fileSystems =
    let
      mkBtrfsMountPoint = subvol: {
        device = "/dev/disk/by-uuid/ce17b7f2-eb3c-4be4-bee2-f76e80feaffd";
        fsType = "btrfs";
        options = [ "subvol=${subvol}" ] ++ helpers.recommendedBtrfsArgs;
      };
    in
    {
      "/" = mkBtrfsMountPoint "@persist";
      "/boot" = {
        device = "/dev/disk/by-uuid/7745-B1D5";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
      "/nix" = mkBtrfsMountPoint "@nix";
    };

  hardware.cpu.intel.updateMicrocode = true;

  networking.useNetworkd = true;

  services = {
    resolved.enable = true;
    thermald.enable = true;
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/0a0168fe-f43d-4fca-b979-b8312747868a"; } ];

  systemd.network = {
    enable = true;
    networks."10-wan" = {
      matchConfig.Name = "enp1s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true; # SLAAC for IPv6
      };
      dhcpV4Config = {
        UseDNS = true;
      };
      linkConfig = {
        # make routing on this interface a dependency for network-online.target
        RequiredForOnline = "routable";
        MTUBytes = 1420;
      };
    };
  };
}
