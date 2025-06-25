{ pkgs, ... }:
{
  linux-firmware = pkgs.linux-firmware.overrideAttrs (oldAttrs: rec {
    version = "20250509";
    src = pkgs.fetchzip {
      url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz";
      hash = "sha256-0FrhgJQyCeRCa3s0vu8UOoN0ZgVCahTQsSH0o6G6hhY=";
    };
  });
}
