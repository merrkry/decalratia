{ lib, user, ... }:
{
  imports = lib.mkModulesList ./.;

  home-manager.users.${user} = {
    imports = [ ./home.nix ];
  };

  profiles = {
    base = {
      enable = true;
      network.tailscale = "client";
    };
    base-devel.enable = true;
    desktop.enable = true;
    tui = {
      helix.enable = true;
      lunarvim.enable = true;
    };
    gui = {
      zed.enable = true;
    };
  };

  users.users = {
    ${user} = {
      hashedPassword = "$2b$05$P8CHQ/cUUelxgi4pSM9Wpeff2SOLBm55oX/81vFq7PyE/PLHpvYfC";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi"
      ];
    };
  };

  time.timeZone = "Europe/Berlin";
}
