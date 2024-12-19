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
