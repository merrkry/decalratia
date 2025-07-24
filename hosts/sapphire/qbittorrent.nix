{ ... }:
{
  services.qbittorrent = {
    enable = true;
    torrentingPort = 56881;
    profileDir = "/var/lib/qbittorrent/";
  };
}
