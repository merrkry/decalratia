{
  config,
  inputs,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.services.syncthing;
  fullDevicesAttr = {
    "akahi" = "U3PBZHL-JZWV4UY-X4Q7UZA-RC4PN2Z-6AXDMB5-B5M7WTE-OUABXFB-IOZB7QE";
    "cryolite" = "2MTCCD2-3QGWJVF-7VKRHOF-IXCOPBJ-ERRC2TQ-W2B4254-PKCRO6M-ZTSRLAP";
    "karanohako" = "6SIYA2F-Q7E32NF-ABSRLXB-3D6YXPB-IEV2PZF-3OOH3NT-ZFGFNHL-75R75Q6";
  };
  filteredDeviceAttr = lib.filterAttrs (name: id: name != cfg.hostname) fullDevicesAttr;
  fullDevicesList = builtins.attrNames fullDevicesAttr;
  filteredDeviceList = lib.filter (name: name != cfg.hostname) fullDevicesList;
in
{
  options.profiles.services.syncthing = {
    enable = lib.mkEnableOption "syncthing";
    hostname = lib.mkOption {
      default = config.networking.hostName;
      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 22000 ];
    };

    sops.secrets = {
      "syncthing" = {
        owner = user;
        sopsFile = "${inputs.secrets}/secrets.yaml";
      };
    };

    home-manager.users.${user} = {
      services.syncthing = {
        enable = true;
        overrideDevices = true;
        overrideFolders = true;
        passwordFile = config.sops.secrets."syncthing".path;
        settings = {
          devices = builtins.mapAttrs (name: id: {
            inherit id;
            autoAcceptFolders = true;
          }) filteredDeviceAttr;
          folders = {
            "Documents" = {
              id = "mkdhn-prnyw";
              path = "~/Documents/Syncthing";
              devices = filteredDeviceList;
              versioning.type = "simple";
              copyOwnershipFromParent = true;
            };
          };
          gui.user = "merrkry";
          options = {
            autoUpgradeIntervalH = "0";
            urAccepted = -1; # disable telemetry
          };
        };
        extraOptions = [ "--no-default-folder" ];
      };
    };
  };
}
