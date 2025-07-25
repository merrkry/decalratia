{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.base-devel.containers;
in
{
  options.profiles.base-devel.containers = {
    enable = lib.mkEnableOption "containers" // {
      default = config.profiles.base-devel.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    virtualisation = {
      containers = {
        enable = true;
        storage.settings = {
          storage = {
            driver = if config.fileSystems."/".fsType == "btrfs" then "btrfs" else "overlay";
            graphroot = "/var/lib/containers/storage";
            runroot = "/run/containers/storage";
          };
        };
      };
      podman = {
        enable = true;
        dockerCompat = false;
        dockerSocket.enable = false;
        defaultNetwork.settings.dns_enabled = true;
        # Runs `podman system prune -f` periodically
        autoPrune.enable = lib.mkDefault true;
      };
    };

    virtualisation.oci-containers.backend = "podman";

    home-manager.users.${user} = {

      home.sessionVariables = {
        DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
      };

    };

  };
}
