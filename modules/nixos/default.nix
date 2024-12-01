{
  base = import ./base.nix;
  base-devel = import ./base-devel.nix;
  desktop = import ./desktop.nix;
  rootfs-cleanup = import ./rootfs-cleanup.nix;
  zswap = import ./zswap.nix;
}
