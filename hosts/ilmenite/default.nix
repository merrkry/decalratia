{ helpers, ... }:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
    base-devel.enable = true;
  };

  time.timeZone = "Europe/Berlin";
}
