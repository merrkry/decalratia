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
      network.tailscale = "client";
    };
    desktop = {
      gaming.enable = true;
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      neovim.enable = true;
    };
    gui = {
      kitty.enable = true;
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
        imagemagick
        materialgram
        obsidian
        qq
        wechat
        zotero
      ];
    };

    services = {
      flatpak.packages = [
        "com.discordapp.Discord"
        "com.spotify.Client"
      ];
    };
  };
}
