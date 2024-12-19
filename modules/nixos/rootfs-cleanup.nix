{ config, lib, ... }:
let
  cfg = config.services.rootfs-cleanup;
in
{
  options.services.rootfs-cleanup = {
    enable = lib.mkEnableOption "clean and backup rootfs BTRFS subvolume";
    uuid = lib.mkOption { type = lib.types.str; };
    mountPoint = lib.mkOption {
      default = "/impermanence";
      type = lib.types.str;
    };
    rootfsSubvol = lib.mkOption { type = lib.types.str; };
    backupSubvol = lib.mkOption { type = lib.types.str; };
    daysToKeep = lib.mkOption {
      default = 7;
      type = lib.types.ints.unsigned;
    };
  };

  config =
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.fileSystems."/".fsType == "btrfs";
          message = "Current rootfs cleanup module only supports BTRFS as rootfs";
        }
        {
          assertion = config.boot.initrd.systemd.enable;
          message = "Current rootfs cleanup module only supports systemd initrd";
        }
      ];

      boot.initrd.supportedFilesystems = [ "btrfs" ];
    }
    // (
      let
        cleanupBtrfs = (
          let
            rootfsPath = "${cfg.mountPoint}/${cfg.rootfsSubvol}";
            bakcupPath = "${cfg.mountPoint}/${cfg.backupSubvol}";
          in
          ''
            mkdir ${cfg.mountPoint}
            mount /dev/disk/by-uuid/${cfg.uuid} ${cfg.mountPoint}
            if [[ -e ${rootfsPath} ]]; then
                rm -rf ${rootfsPath}/tmp
                mkdir -p ${bakcupPath}
                timestamp=$(date --date="@$(stat -c %Y ${rootfsPath})" "+%Y-%m-%-d_%H:%M:%S")
                mv ${rootfsPath} "${bakcupPath}/$timestamp"
            fi

            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "${cfg.mountPoint}/$i"
                done
                btrfs subvolume delete "$1"
            }

            for i in $(find ${bakcupPath} -maxdepth 1 -mtime +${toString cfg.daysToKeep}); do
                delete_subvolume_recursively "$i"
            done

            btrfs subvolume create ${rootfsPath}
            umount ${cfg.mountPoint}
          ''
        );
      in
      {
        # https://discourse.nixos.org/t/impermanence-vs-systemd-initrd-w-tpm-unlocking/25167
        boot.initrd.systemd.services."rootfs-cleanup" = {
          wantedBy = [ "initrd.target" ];
          # TODO: make a module option for this, in order to work with more complex luks/zfs/lvm setups.
          after = [ "initrd-root-device.target" ];
          before = [ "sysroot.mount" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = cleanupBtrfs;
        };
      }
    );
}
