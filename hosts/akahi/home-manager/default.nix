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
    ./dev.nix
    ./mpv.nix
    ./niri.nix
    ./themes.nix
    ./xdg.nix
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
    jetbrains-toolbox
    tsukimi
    eog
    jdk17 # FIXME: move to shell.nix
    podman-compose
    distrobox
    (obsidian.override { commandLineArgs = lib.ChromiumArgs; })
    neovim
    rar
    zip
    kdePackages.ark
    kdePackages.qtsvg
    mangohud
    starsector
    (prismlauncher.override {
      jdks = [
        # TODO: package graalvm-ee
        jdk17
      ];
    })
    looking-glass-client-git
    evince
    nixd
    nixfmt-rfc-style
  ];

  # TODO: move to dev.nix
  programs.vscode = {
    enable = true;
    # this will let home-manager manage ~/.config/Code/User/settings.json
    enableUpdateCheck = lib.mkForce false;
    package = pkgs.vscode.override { commandLineArgs = lib.ChromiumArgs; };
  };
}
