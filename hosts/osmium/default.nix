{
  helpers,
  lib,
  pkgs,
  user,
  ...
}:
{
  imports = helpers.mkModulesList ./.;

  profiles = {
    meta = {
      type = "desktop";
    };
    base = {
      network.tailscale = null;
    };
    desktop = {
      gaming.enable = true;
    };
    cli = {
      devTools.enable = true;
    };
    tui = {
      neovim.enable = true;
    };
    gui = {
      thunderbird.enable = true;
      vscode.enable = true;
    };
    services = {
      rclone.enable = true;
      syncthing.enable = true;
    };
  };

  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "sekai0" ];
    allowedUDPPorts = [ 41641 ];
  };

  services = {
    sing-box.enable = true;
  };

  # TODO: upstream this.
  systemd.services.sing-box.serviceConfig = {
    ConfigurationDirectory = "sing-box";
    ExecStartPre = lib.mkForce "";
    ExecStart = lib.mkForce [
      ""
      "${lib.getExe pkgs.sing-box} -D \${STATE_DIRECTORY} -C \${CONFIGURATION_DIRECTORY} run"
    ];
  };

  home-manager.users.${user} = {
    home = {
      packages = with pkgs; [
        anki
        materialgram
        obsidian
        zotero
      ];
    };

    services = {
      flatpak.packages = [
        "com.discordapp.Discord"
        "com.qq.QQ"
        "com.spotify.Client"
        "com.tencent.WeChat"
      ];
    };
  };
}
