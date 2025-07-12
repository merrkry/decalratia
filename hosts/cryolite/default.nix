{
  user,
  helpers,
  ...
}:
{
  imports = helpers.mkModulesList ./.;

  home-manager.users.${user} = {
    imports = [ ./home.nix ];
  };

  profiles = {
    base = {
      enable = true;
      network.tailscale = "client";
    };
    base-devel.enable = true;
    desktop = {
      enable = true;
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

  time.timeZone = "Europe/Berlin";
}
