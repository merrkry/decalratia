{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  ChromiumArgs = builtins.foldl' (x: y: x + " " + y) "" [
    "--ozone-platform-hint=auto"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
    "--password-store=gnome-libsecret"
  ];
in
{
  imports = [
    ./dev.nix
    ./mpv.nix
    ./niri.nix
    ./rclone.nix
    ./themes.nix
    ./waybar.nix
    ./xdg.nix
  ];

  home = {
    username = "merrkry";
    homeDirectory = "/home/merrkry";
  };

  home.sessionVariables = {
    LANG = "zh_CN.UTF-8";
    XMODIFIERS = "@im=fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    QT_IM_MODULES = "wayland;fcitx;ibus";

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
    (ungoogled-chromium.override {
      commandLineArgs = ChromiumArgs;
      enableWideVine = true;
    })
    jdk17 # FIXME: move to shell.nix
    podman-compose
    distrobox
    (obsidian.override { commandLineArgs = ChromiumArgs; })
    neovim
    rar
    zip
    kdePackages.ark
    kdePackages.qtsvg
    ncpamixer
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
  ];

  # TODO: move to dev.nix
  programs.vscode = {
    enable = true;
    # this will let home-manager manage ~/.config/Code/User/settings.json
    enableUpdateCheck = lib.mkForce false;
    package = pkgs.vscode.override { commandLineArgs = ChromiumArgs; };
  };

  systemd.user.services."swaybg" = {
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Unit = {
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.swaybg} -i ${osConfig.stylix.image} -m fill";
      Restart = "on-failure";
    };
  };

  services.playerctld.enable = true;
}
