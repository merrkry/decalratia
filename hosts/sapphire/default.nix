{ user, helpers, ... }:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    meta = {
      type = "base";
    };
    base = {
      network.tailscale = "server";
    };
  };

  users.users.${user}.extraGroups = [ "qbittorrent" ];
}
