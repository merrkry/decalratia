{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.presets.desktop;
in
{
  options.presets.desktop = {
    enable = lib.mkEnableOption "desktop" // {
      default = true;
    };
    enable32Bit = lib.mkEnableOption "32 bit support" // {
      default = true;
    };
    disableWatchdog = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = ''
        Disable watchdog.
        It is controversial whether it helps with performance/powersaving.
      '';
    };
    enablePlymouth = lib.mkEnableOption "plymouth" // {
      default = true;
    };
    enableLocale = lib.mkEnableOption "locale" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        hardware.graphics = {
          enable = true;
          enable32Bit = cfg.enable32Bit;
        };

        security.rtkit.enable = true;
        hardware.pulseaudio.enable = false;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
          jack.enable = cfg.enable32Bit;

          extraConfig = {
            pipewire."92-low-latency" = {
              "context.properties" = {
                "default.clock.rate" = 48000;
                "default.clock.quantum" = 32;
                "default.clock.min-quantum" = 32;
                "default.clock.max-quantum" = 32;
              };
            };
            pipewire-pulse."92-low-latency" = {
              "context.properties" = [
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = { };
                }
              ];
              "pulse.properties" = {
                "pulse.min.req" = "32/48000";
                "pulse.default.req" = "32/48000";
                "pulse.max.req" = "32/48000";
                "pulse.min.quantum" = "32/48000";
                "pulse.max.quantum" = "32/48000";
              };
              "stream.properties" = {
                "node.latency" = "32/48000";
                "resample.quality" = 1;
              };
            };
          };
        };

        programs.cfs-zen-tweaks.enable = true;

        boot.kernelParams = [
          # "nowatchdog"

          "preempt=full"

          "split_lock_detect=off"

          # https://wiki.cachyos.org/configuration/general_system_tweaks
          "rcutree.enable_rcu_lazy=1"
        ];

        boot.kernel.sysctl = {
          "vm.max_map_count" = 2147483642;
          "kernel.sched_cfs_bandwidth_slice_us" = 3000;
          "kernel.split_lock_mitigate" = 0;

          "kernel.panic" = 10;
          "kernel.sysrq" = 1;
        };

        services.udev.extraRules = ''
          # HDD
          ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

          # SSD
          ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"

          # NVMe SSD
          ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="kyber"
        '';

        # required by home-manager xdg.portal.enable
        environment.pathsToLink = [
          "/share/xdg-desktop-portal"
          "/share/applications"
        ];

        services.flatpak.enable = true;
        systemd.services."update-system-flatpaks" = {
          description = "Update system Flatpaks";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = pkgs.writeShellScript "update-system-flatpaks" ''
              ${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive --system
              ${pkgs.flatpak}/bin/flatpak uninstall --unused --assumeyes --noninteractive --system
            '';
          };
        };
        systemd.timers."update-system-flatpaks" = {
          description = "Update system Flatpaks";
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "default.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
          };
        };

        programs.appimage = {
          enable = true;
          binfmt = true;
        };

        services.xserver.excludePackages = with pkgs; [ xterm ];

      }

      (lib.mkIf cfg.disableWatchdog {
        boot.kernelParams = [ "nowatchdog" ];
        boot.extraModprobeConfig = ''
          blacklist iTCO_wdt
          blacklist sp5100_tco
        '';
      })

      (lib.mkIf cfg.enablePlymouth {
        boot = {
          plymouth.enable = true;

          # Enable "Silent Boot"
          consoleLogLevel = 0;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
          ];
          # Hide the OS choice for bootloaders.
          # It's still possible to open the bootloader list by pressing any key
          # It will just not appear on screen unless a key is pressed
          loader.timeout = 0;
        };
      })

      (lib.mkIf cfg.enableLocale {

        i18n = {
          defaultLocale = "en_US.UTF-8";
          supportedLocales = [
            "zh_CN.UTF-8/UTF-8"
            "en_US.UTF-8/UTF-8"
          ];
          inputMethod = {
            enable = true;
            type = "fcitx5";
            fcitx5 = {
              addons = with pkgs; [
                fcitx5-chinese-addons
                fcitx5-pinyin-zhwiki
                fcitx5-pinyin-moegirl
                fcitx5-pinyin-minecraft

                fcitx5-pinyin-custompinyindict
              ];
              waylandFrontend = true;
            };
          };
        };

        fonts = {
          fontDir.enable = true;

          # https://github.com/NixOS/nixpkgs/blob/fa42b5a5f401aab8a32bd33c9a4de0738180dc59/nixos/modules/config/fonts/packages.nix#L34C1-L41C8
          enableDefaultPackages = true;

          packages = with pkgs; [
            noto-fonts
            dejavu_fonts

            noto-fonts-color-emoji

            noto-fonts-cjk-sans
            noto-fonts-cjk-serif

            # for compatibility with old app that doesn't support variable fonts
            noto-fonts-cjk-sans-static
            noto-fonts-cjk-serif-static

            bookerly
            lxgw-wenkai

            jetbrains-mono
            nerd-fonts.symbols-only

            ibm-plex
          ];

          fontconfig = {
            enable = true;

            # https://catcat.cc/post/2021-03-07/
            localConf = ''
              <match target="pattern">
                <test name="family">
                  <string>system-ui</string>
                </test>
                <edit name="family" mode="prepend" binding="strong">
                  <string>sans-serif</string>
                </edit>
              </match>
            '';

            defaultFonts = {
              sansSerif = [
                "IBM Plex Sans"
                "Noto Sans CJK SC"
                "Noto Sans CJK TC"
                "Noto Sans CJK JP"
                "Noto Sans CJK KR"
                "Noto Color Emoji"
                "Symbols Nerd Font"
              ];

              serif = [
                "Bookerly"
                "LXGW WenKai"
                "Noto Serif CJK SC"
                "Noto Serif CJK TC"
                "Noto Serif CJK JP"
                "Noto Serif CJK KR"
                "Noto Color Emoji"
                "Symbols Nerd Font"
              ];

              monospace = [
                "JetBrains Mono"
                "Noto Sans Mono CJK SC"
                "Noto Sans Mono CJK TC"
                "Noto Sans Mono CJK JP"
                "Noto Sans Mono CJK KR"
                "Noto Color Emoji"
                "Symbols Nerd Font Mono"
              ];

              emoji = [ "Noto Color Emoji" ];
            };

            subpixel.rgba = "rgb";
          };
        };

      })
    ]
  );
}
