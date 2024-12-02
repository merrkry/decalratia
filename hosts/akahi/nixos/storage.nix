{
  config,
  lib,
  pkgs,
  ...
}:
let
  mkBtrfsMount = subvol: {
    device = "/dev/disk/by-uuid/ba21d45a-15fc-4af8-8793-b06ddb4407c5";
    fsType = "btrfs";
    options = [
      (if subvol != "" then "subvol=" + subvol else null)
      "noatime"
      "compress=zstd"
    ];
  };
in
{
  rootfs-cleanup = {
    enable = true;
    uuid = "ba21d45a-15fc-4af8-8793-b06ddb4407c5";
    rootfsSubvol = "@nixos/@rootfs";
    backupSubvol = "@nixos/@rootfs-old";
  };

  fileSystems."/btrfs-root" = mkBtrfsMount "/";
  fileSystems."/" = mkBtrfsMount "@nixos/@rootfs";
  fileSystems."/nix" = mkBtrfsMount "@nixos/@nix";
  fileSystems."/persist" = (mkBtrfsMount "@nixos/@persist") // {
    neededForBoot = true;
  };

  fileSystems."/var/lib/libvirt/images" = mkBtrfsMount "@nixos/@images";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/ECE8-D259";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/60005c5c-54dc-4ead-b28f-021d2f84c177"; }
    { device = "/dev/disk/by-uuid/6b2a6972-1f3c-45f3-a28a-ad2f215f9881"; }
  ];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var"
      "/etc/NetworkManager/system-connections"
      "/root"
      "/home"
      "/etc/asusd"
      "/etc/sing-box"
      "/etc/libvirt"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  services.snapper = {
    persistentTimer = true;
    configs = {
      "persist" = {
        SUBVOLUME = "/persist";

        ALLOW_GROUPS = [ "wheel" ];

        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_LIMIT_HOURLY = 12;
        TIMELINE_LIMIT_DAILY = 7;
        TIMELINE_LIMIT_WEEKLY = 2;
        TIMELINE_LIMIT_MONTHLY = 0;
        TIMELINE_LIMIT_QUARTERLY = 0;
        TIMELINE_LIMIT_YEARLY = 0;
      };
    };
  };
}
