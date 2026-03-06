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

  time.timeZone = "Europe/Zurich";

  users.users.${user}.extraGroups = [ "qbittorrent" ];
}
