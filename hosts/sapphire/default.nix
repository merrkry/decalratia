{
  lib,
  user,
  helpers,
  ...
}:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
  };

  users.users.${user}.extraGroups = [ "qbittorrent" ];

  time.timeZone = "Europe/Luxembourg";
}
