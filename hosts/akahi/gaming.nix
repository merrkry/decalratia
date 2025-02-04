{ pkgs, user, ... }:
{
  programs = {
    gamescope.enable = true;

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      localNetworkGameTransfers.openFirewall = true;
      dedicatedServer.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };

  home-manager.users.${user} = {
    home = {
      packages = with pkgs; [
        mangohud
        (prismlauncher.override {
          jdks = [
            # TODO: package graalvm-ee
            jdk17
          ];
        })
        starsector
      ];

      sessionVariables = {
        DXVK_ASYNC = "1";
        PROTON_ENABLE_NVAPI = "1";
        PROTON_ENABLE_NGX_UPDATER = "1";
      };
    };
  };
}
