{ helpers, ... }:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
    };
  };

  time.timeZone = "Europe/Berlin";
}
