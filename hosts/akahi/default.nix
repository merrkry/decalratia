{
  helpers,
  pkgs,
  user,
  ...
}:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    meta = {
      type = "desktop";
    };
    base = {
      backup.snapperConfigs = {
        "persist" = "/";
      };
      network.tailscale = "client";
    };
    desktop = {
      gaming = {
        enable = true;
        enableNTSync = true;
      };
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
      neovim.enable = true;
    };
    gui = {
      foot.enable = true;
      thunderbird.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
  };

  home-manager.users.${user} = {
    home = {
      packages = with pkgs; [
        anki
        (cherry-studio.override { commandLineArgs = helpers.chromiumArgs; })
        distrobox
        imagemagick
        libreoffice-fresh
        materialgram
        nali
        numbat
        obsidian
        podman-compose
        (prismlauncher.override {
          jdks = [
            jdk8
            jdk17
            jdk21
            jdk25
          ];
        })
        q
        tsukimi
        xournalpp
      ];
    };

    services = {
      flatpak.packages = [
        "app.zen_browser.zen"
        "com.discordapp.Discord"
        "com.qq.QQ"
        "com.spotify.Client"
        "com.tencent.WeChat"
        "com.usebottles.bottles"
      ];
    };
  };
}
