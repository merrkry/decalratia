{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.gvfs.enable = true;

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
