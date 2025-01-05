{ lib, user, ... }:
{
  imports = lib.mkModulesList ./.;
  home-manager.users.${user}.imports = [ ./home.nix ];

  profiles = {
    base = {
      enable = true;
      backup.snapperConfigs = {
        "persist" = "/";
      };
      network.tailscale = "client";
    };
    base-devel.enable = true;
    desktop.enable = true;
    tui = {
      helix.enable = true;
      lunarvim.enable = true;
    };
    gui = {
      vscode.enable = true;
      zed.enable = true;
    };
  };

  users.users = {
    "merrkry" = {
      hashedPassword = "$y$j9T$0RaEe1vqgRkZZPv9t9p6b0$RgZyFgbLwUkFwT7TmLcvn5aTfix7.K3x/hz/FPQP71D";
      isNormalUser = true;
      openssh.authorizedKeys.keys = lib.sshKeys.trusted;
      extraGroups = [
        "wheel"
        "libvirtd"
        "kvm"
      ];
    };
  };

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  time.timeZone = "Europe/Berlin";
}
