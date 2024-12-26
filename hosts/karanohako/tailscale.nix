{ lib, pkgs, ... }:
{
  services = {
    # udp performance tuning, see https://wiki.nixos.org/wiki/Tailscale
    networkd-dispatcher = {
      enable = true;
      rules."50-tailscale" = {
        onState = [ "routable" ];
        script = ''
          ${lib.getExe pkgs.ethtool} -K eth0 rx-udp-gro-forwarding on rx-gro-list off
        '';
      };
    };

    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
    };
  };
}
