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
  fileSystems."/btrfs-root" = mkBtrfsMount "/";
  fileSystems."/" = mkBtrfsMount "@nixos/@persist";
  fileSystems."/nix" = mkBtrfsMount "@nixos/@nix";

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
}
