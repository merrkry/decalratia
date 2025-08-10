{
  config,
  lib,
  user,
  helpers,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  imports = helpers.mkModulesList ./.;

  options.profiles.base = {
    enable = lib.mkEnableOption "base profile";
    enableGlobalKSM = lib.mkEnableOption "global KSM";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot = {
          tmp.cleanOnBoot = true;
          initrd.systemd.enable = true;
        };

        # workarounds for rootless podman subuid/subgid
        # only works for main user
        # more see https://github.com/linyinfeng/dotfiles/blob/main/nixos/modules/users/userborn-extra.nix
        # and https://github.com/nikstur/userborn/issues/7
        environment.etc =
          let
            autosubs = {
              text = ''
                ${user}:100000:65536
              '';
              mode = "0444";
            };
          in
          {
            "subgid" = autosubs;
            "subuid" = autosubs;
          };

        security = {
          polkit.enable = true;

          sudo.extraConfig = ''
            Defaults lecture="never"
          '';
        };

        services = {
          automatic-timezoned.enable = true;

          # IMPORTANT: this is broken on first-time deployment! Install the system with this disabled, and then enable this via rebuild.
          # currently breaks rootless podman due to lack of subuid and subgid support,
          # see https://github.com/nikstur/userborn/issues/7
          userborn = {
            enable = true;
            passwordFilesLocation = "/var/lib/nixos";
          };
        };

        system.etc.overlay = {
          enable = true;
          mutable = true;
        };

        systemd = {
          settings.Manager = {
            DefaultLimitNOFILE = "2048:2097152";
          };
          user.extraConfig = ''
            DefaultLimitNOFILE=1024:1048576
          '';
        };

        users.mutableUsers = false;

        home-manager.users.${user} = {
          home.stateVersion = config.system.stateVersion;
          systemd.user.startServices = "sd-switch";
        };
      }
      (lib.mkIf cfg.enableGlobalKSM {
        # https://github.com/CachyOS/CachyOS-PKGBUILDS/tree/master/cachyos-ksm-settings
        systemd = {
          services =
            let
              ksmConfig = {
                MemoryKSM = "yes";
              };
            in
            {
              "getty@".serviceConfig = ksmConfig;
              "user@".serviceConfig = ksmConfig;
              # display managers
              "greetd".serviceConfig = ksmConfig;
            };

          tmpfiles.rules = [ "w! /sys/kernel/mm/ksm/run - - - - 1" ];
        };
      })
    ]
  );
}
