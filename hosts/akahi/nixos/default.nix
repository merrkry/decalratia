{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
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

  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  boot.kernelParams = [
    "rcutree.enable_rcu_lazy=1" # https://wiki.cachyos.org/configuration/general_system_tweaks
  ];

  boot.kernel.sysctl = {
    "vm.page-cluster" = 1;
  };

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

    # charge_control_end_threshold is modified by the daemon according to current value in the system
    # should be fine with TLP
    asusdConfig = ''
      (
          charge_control_end_threshold: 100,
          panel_od: false,
          boot_sound: false,
          mini_led_mode: false,
          disable_nvidia_powerd_on_battery: true,
          ac_command: "${lib.getExe pkgs.brightnessctl} set 100%",
          bat_command: "${lib.getExe pkgs.brightnessctl} set 25%",
          throttle_policy_linked_epp: false,
          throttle_policy_on_battery: Quiet,
          change_throttle_policy_on_battery: false,
          throttle_policy_on_ac: Performance,
          change_throttle_policy_on_ac: false,
          throttle_quiet_epp: Power,
          throttle_balanced_epp: BalancePower,
          throttle_performance_epp: Performance,
          ppt_pl1_spl: Some(45),
          ppt_pl2_sppt: Some(65),
          nv_dynamic_boost: Some(0),
          nv_temp_target: Some(87),
      )
    '';
  };
  services.supergfxd.enable = false;

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };
}
