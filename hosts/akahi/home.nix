{ lib, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      imagemagick
      ghostscript_headless
      nali
      q
      gparted
      anki
      tsukimi
      podman-compose
      distrobox
      (obsidian.override { commandLineArgs = lib.ChromiumArgs; })
      mangohud
      starsector
      (prismlauncher.override {
        jdks = [
          # TODO: package graalvm-ee
          jdk17
        ];
      })
      jetbrains.idea-ultimate
      materialgram
      xournalpp
      kdePackages.kdenlive
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
}
