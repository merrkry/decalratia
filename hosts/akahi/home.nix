{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      anki
      distrobox
      gparted
      imagemagick
      jetbrains.idea-ultimate
      kdePackages.kdenlive
      materialgram
      nali
      nodejs
      (obsidian.override { commandLineArgs = lib.chromiumArgs; })
      podman-compose
      q
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
    ];
  };
}
