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
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
    };
    gui = {
      vscode.enable = true;
      zed.enable = true;
    };
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
  };

  home-manager.users.${user} = {
    home.packages = with pkgs; [
      distrobox
      materialgram
      obsidian
      xournalpp
    ];

    services.flatpak.packages = [ ];
  };
}
