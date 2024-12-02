{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "akahi";
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
      # wifi.backend = "iwd";
    };
  };
  services.resolved = {
    enable = true;
    dnsovertls = "opportunistic";
    dnssec = "allow-downgrade";
  };
}
