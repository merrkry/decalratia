{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.base;
in
{
  imports = lib.mkModulesList ./.;

  options.profiles.base = {
    enable = lib.mkEnableOption "base profile";
  };

  config = lib.mkIf cfg.enable {

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

    # IMPORTANT: this is broken on first-time deployment! Install the system with this disabled, and then enable this via rebuild.
    # currently breaks rootless podman due to lack of subuid and subgid support,
    # see https://github.com/nikstur/userborn/issues/7
    services.userborn = {
      enable = true;
      passwordFilesLocation = "/var/lib/nixos";
    };

    systemd.user.extraConfig = ''
      DefaultLimitNOFILE=524288
    '';

    users.mutableUsers = false;

    home-manager.users.${user} = {

      home.stateVersion = config.system.stateVersion;
      systemd.user.startServices = "sd-switch";

    };

  };
}
