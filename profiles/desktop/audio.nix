{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.desktop.audio;
in
{
  options.profiles.desktop.audio = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {

    security = {
      pam.loginLimits = [
        {
          domain = "@audio";
          item = "memlock";
          type = "-";
          value = "unlimited";
        }
        {
          domain = "@audio";
          item = "rtprio";
          type = "-";
          value = "99";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "soft";
          value = "99999";
        }
        {
          domain = "@audio";
          item = "nofile";
          type = "hard";
          value = "99999";
        }
      ];

      rtkit.enable = true;
    };

    services = {
      udev.extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      '';
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = lib.mkDefault config.profiles.desktop.enable32Bit;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    users.users.${user}.extraGroups = [ "audio" ];

    home-manager.users.${user} = {

      services.playerctld.enable = true;

      home.packages = with pkgs; [ pavucontrol ];

    };

  };
}
