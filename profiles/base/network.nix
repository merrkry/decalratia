{ config, lib, ... }:
let
  cfg = config.profiles.base.network;
in
{
  options.profiles.base.network = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
  };

  config = lib.mkIf cfg.enable {

    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion" = "bbr";
      "net.ipv4.tcp_slow_start_after_idle" = 0;
      "net.ipv4.tcp_notsent_lowat" = 16384;
    };

    environment.sessionVariables = {
      HOSTNAME = config.networking.hostName;
    };

    networking.firewall.enable = true;

    services.bpftune.enable = true;

    services.timesyncd.enable = false;
    services.chrony = {
      enable = true;
      enableNTS = true;
      servers = [ "time.cloudflare.com" ];
    };

  };
}
