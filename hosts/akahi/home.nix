{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      anki
      distrobox
      gparted
      imagemagick
      joystickwake
      kdePackages.kdenlive
      materialgram
      nali
      nodejs
      numbat
      (obsidian.override { commandLineArgs = lib.chromiumArgs; })
      podman-compose
      (prismlauncher.override { jdks = [ jdk17 ]; })
      q
      tsukimi
      xournalpp

      go
      golangci-lint
      gopls
      gotools
    ];
  };

  services = {
    flatpak.packages = [
      "com.baidu.NetDisk"
      "com.qq.QQ"
      "com.usebottles.bottles"
      "com.valvesoftware.Steam"
      "runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08" # need to match the version that steam is built on
      "runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE/x86_64/stable"
    ];
  };
}
