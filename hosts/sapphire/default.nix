{ lib, user, ... }:
{
  imports = lib.mkModulesList ./.;

  profiles = {
    base = {
      enable = true;
      network.tailscale = "server";
    };
  };

  users.users = {
    ${user} = {
      extraGroups = [ "qbittorrent" ];
      hashedPassword = "$y$j9T$xLHLqiVYRqwaJ7NjWcKgE0$.TGv4WGPvGguZ62GN7coV0xo8l6l4Rm7XDwkyFdoKX6";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHylx0U1U4NlR9RIadf1vGlKf/C+dJN9GC9oGhwQlMZd merrkry@hoshinouta"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAg9BDaX6NeZmA3ux+Zr5Dd6zhBCu4Ohs0iORgojXN4 merrkry@karanohako"
      ];
    };
  };

  time.timeZone = "Europe/Luxembourg";
}
