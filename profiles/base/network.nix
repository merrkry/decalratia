{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.base.network;
in
{
  options.profiles.base.network = {
    enable = lib.mkEnableOption' { default = config.profiles.base.enable; };
    tailscale = lib.mkOption {
      default = null;
      type = lib.types.nullOr (
        lib.types.enum [
          "client"
          "server"
          "both"
        ]
      );
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
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

        security.acme = {
          acceptTerms = true;
          defaults.email = "security@tsubasa.moe";
        };

        services = {
          bpftune.enable = true;

          chrony = {
            enable = true;
            enableNTS = true;
            servers = [ "time.cloudflare.com" ];
          };

          nginx = {
            recommendedProxySettings = true;
            recommendedTlsSettings = true;
            virtualHosts = {
              "_" = {
                default = true;
                extraConfig = ''
                  listen 443 ssl default_server;
                  ssl_reject_handshake on;
                  error_page 497 =444 /;
                  return 444;
                '';
              };
            };
          };

          timesyncd.enable = false;
        };
      }
      (lib.mkIf (cfg.tailscale != null) {
        services.tailscale = {
          enable = true;
          openFirewall = true;
          useRoutingFeatures = cfg.tailscale;
        };

        # https://tailscale.com/kb/1320/performance-best-practices#linux-optimizations-for-subnet-routers-and-exit-nodes
        systemd.services."tailscale-tuning" = {
          # NetworkManager will not trigger this. This is ideal, because it's very trick to manage the (re)start of it, and it mainly benefits routing devices.
          wantedBy = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
          };
          enableStrictShellChecks = true;
          script = ''
            NETDEV=$(${lib.getExe' pkgs.iproute2 "ip"} -o route get 1.1.1.1 | ${lib.getExe' pkgs.coreutils "cut"} -f 5 -d " ")
            ${lib.getExe pkgs.ethtool} -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
          '';
        };
      })
    ]
  );
}
