{ config, ... }:
{
  services.qbittorrent = {
    enable = true;
    webuiPort = config.lib.ports.qbittorrent;
    torrentingPort = 16881;
  };
}
