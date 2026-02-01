{ config, lib, ... }:
let
  cfg = config.profiles.desktop.network;
in
{
  options.profiles.desktop.network = {
    enable = lib.mkEnableOption "network";
  };

  config = lib.mkIf cfg.enable {
    networking = {
      useDHCP = false;
      dhcpcd.enable = false;
      networkmanager = {
        enable = true;
        dns = "systemd-resolved";
        dhcp = "internal";
        connectionConfig = {
          "ethernet.wake-on-lan" = "ignore";
          "wifi.wake-on-wlan" = "ignore";
          "wifi.powersave" = lib.mkForce "3";
        };
        # idk how to connect eduroam with iwd
        # wifi.backend = "iwd";
      };
    };

    services.resolved = {
      enable = true;
      settings = {
        Resolve = {
          DNSOverTLS = "no";
          DNSSEC = false;
        };
      };
    };
  };
}
