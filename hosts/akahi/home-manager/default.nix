{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let

in
{
  imports = [
    ./mpv.nix
    ./niri.nix
    ./themes.nix
  ];

  home.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };

  home.packages = with pkgs; [
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
    neovim
    mangohud
    starsector
    (prismlauncher.override {
      jdks = [
        # TODO: package graalvm-ee
        jdk17
      ];
    })
    looking-glass-client-git
    jetbrains.idea-ultimate
    materialgram
  ];
}
