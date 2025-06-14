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
    desktop = {
      enable = true;
      waybar.backlightDevice = "amdgpu_bl1";
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
    };
    gui = {
      vscode.enable = true;
      zed.enable = true;
    };
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
  };

  users.users = {
    ${user} = {
      hashedPassword = "$2b$05$P8CHQ/cUUelxgi4pSM9Wpeff2SOLBm55oX/81vFq7PyE/PLHpvYfC";
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
    };
  };

  time.timeZone = "Europe/Berlin";
}
