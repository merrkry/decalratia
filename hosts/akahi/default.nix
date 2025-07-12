{
  lib,
  user,
  helpers,
  ...
}:
{
  imports = helpers.mkModulesList ./.;
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
    desktop = {
      enable = true;
      gaming.enable = true;
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      helix.enable = true;
    };
    gui = {
      librewolf.enable = true;
      thunderbird.enable = true;
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
      isNormalUser = true;
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
