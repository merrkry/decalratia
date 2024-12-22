{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ./desktop.nix
    ./graphics.nix
    ./power.nix
    ./storage.nix
    ./virtualisation.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 16;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.editor = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "usb_storage"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;

  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  services.supergfxd.enable = false;

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };
}
