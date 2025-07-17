{ helpers, ... }:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    meta = {
      type = "base-devel";
    };
    base = {
      network.tailscale = "server";
    };
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
}
