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
  };
}
