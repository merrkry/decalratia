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

  # Archlinux realtime-privileges / CachyOS-Settings
  # https://cmm.github.io/soapbox/the-year-of-linux-on-the-desktop.html
  config = lib.mkIf cfg.enable {
    boot.kernelParams = [ "threadirqs" ];

    environment.etc."wireplumber/main.lua.d/99-alsa-config.lua".text = ''
      -- prepend, otherwise the change-nothing stock config will match first:
      table.insert(alsa_monitor.rules, 1, {
        matches = {
          {
            -- Matches all sinks.
            { "node.name", "matches", "alsa_output.*" },
          },
        },
        apply_properties = {
          ["api.alsa.headroom"] = 1024,
        },
      })
    '';

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
        DEVPATH=="/devices/virtual/misc/hpet", OWNER="root", GROUP="audio", MODE="0660"
      '';
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = lib.mkDefault config.profiles.desktop.enable32Bit;
        pulse.enable = true;
        jack.enable = true;
      };
    };

    systemd.tmpfiles.rules = [
      "w! /sys/class/rtc/rtc0/max_user_freq - - - - 3072"
      "w! /proc/sys/dev/hpet/max-user-freq  - - - - 3072"
    ];

    users.users.${user}.extraGroups = [ "audio" ];

    home-manager.users.${user} = {
      services.playerctld.enable = true;

      home.packages = with pkgs; [ pavucontrol ];
    };
  };
}
