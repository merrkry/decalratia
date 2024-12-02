{
  config,
  lib,
  pkgs,
  ...
}:
{
  niri-flake.cache.enable = false;
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${lib.getExe pkgs.greetd.tuigreet} --cmd niri-session";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  security.pam = {
    services."greetd".enableGnomeKeyring = true;
  };

  services.gvfs.enable = true;

  programs.firefox = {
    enable = true;
    languagePacks = [
      "en-US"
      "zh-CN"
    ];
  };

  programs.thunderbird.enable = true;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  programs.xfconf.enable = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    localNetworkGameTransfers.openFirewall = true;
    dedicatedServer.openFirewall = true;
    remotePlay.openFirewall = true;
  };
  programs.gamescope.enable = true;

  environment.sessionVariables = {
    DXVK_ASYNC = "1";
    PROTON_ENABLE_NVAPI = "1";
    PROTON_ENABLE_NGX_UPDATER = "1";
  };
}
