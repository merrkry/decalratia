{
  helpers,
  lib,
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
        cherry-studio
        distrobox
        gapless
        imagemagick
        krita
        libreoffice-fresh
        materialgram
        nali
        numbat
        obsidian
        podman-compose
        prismlauncher
        q
        tsukimi
        xournalpp
        zotero
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
