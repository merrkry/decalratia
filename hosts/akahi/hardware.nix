{
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "xhci_pci"
      "nvme"
      "usbhid"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 16;
        consoleMode = "auto";
        editor = true;
      };
    };
    kernelModules = [ "kvm-amd" ];
  };

  environment.systemPackages = with pkgs; [ nvtopPackages.amd ];

  fileSystems =
    let
      mkBtrfsMount = subvol: {
        device = "/dev/disk/by-uuid/ba21d45a-15fc-4af8-8793-b06ddb4407c5";
        fsType = "btrfs";
        options = [ (if subvol != "" then "subvol=" + subvol else null) ] ++ lib.recommendedBtrfsArgs;
      };
    in
    {
      "/btrfs-root" = mkBtrfsMount "/";
      "/" = mkBtrfsMount "@nixos/@persist";
      "/nix" = mkBtrfsMount "@nixos/@nix";
      "/var/lib/libvirt/images" = mkBtrfsMount "@nixos/@images";
      "/boot" = {
        device = "/dev/disk/by-uuid/ECE8-D259";
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
        ];
      };
    };

  hardware = {
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/60005c5c-54dc-4ead-b28f-021d2f84c177"; } ];
}
