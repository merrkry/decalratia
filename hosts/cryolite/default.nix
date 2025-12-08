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
      network.tailscale = "client";
    };
    desktop = {
      waybar.backlightDevice = "amdgpu_bl1";
      tweaks.scheduler = "scx_cosmos";
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
      neovim.enable = true;
    };
    gui = {
      thunderbird.enable = true;
      vscode.enable = true;
      zed.enable = true;
    };
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
  };

  services.scx.extraArgs = [
    "--primary-domain"
    "powersave"
    "--no-deferred-wakeup"
    "--polling-ms"
    "5000"
  ];

  home-manager.users.${user} = {
    home.packages = with pkgs; [
      distrobox
      materialgram
      obsidian
      xournalpp
      zotero
    ];

    services.flatpak.packages = [
      "com.discordapp.Discord"
    ];
  };
}
