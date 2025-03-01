{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      anki
      distrobox
      gparted
      imagemagick
      jetbrains.idea-ultimate
      joystickwake
      kdePackages.kdenlive
      materialgram
      nali
      nodejs
      (obsidian.override { commandLineArgs = lib.chromiumArgs; })
      podman-compose
      (prismlauncher.override { jdks = [ jdk17 ]; })
      q
      starsector
      tsukimi
      xournalpp
    ];
  };

  programs.niri.settings.outputs = {
    "eDP-1" = {
      scale = 1.6;
      variable-refresh-rate = "on-demand";
      position = {
        x = 2560; # 3840 / 1.5
        y = 540; # 2160 / 1.5 - 1440 / 1.6
      };
    };
    "DP-1" = {
      mode = {
        width = 3840;
        height = 2160;
        refresh = 143.998;
      };
      position = {
        x = 0;
        y = 0;
      };
      scale = 1.5;
      variable-refresh-rate = "on-demand";
    };
  };

  services = {
    flatpak.packages = [
      "com.baidu.NetDisk"
      "com.qq.QQ"
      "com.tencent.WeChat"
      "com.usebottles.bottles"
      "com.valvesoftware.Steam"
      "runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08" # need to match the version that steam is built on
      "runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE/x86_64/stable"
    ];
  };
}
