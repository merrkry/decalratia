{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.presets.base-devel;
in
{
  options.presets.base-devel = {
    enable = lib.mkEnableOption "base-devel" // {
      default = true;
    };
    enableHardwareUtils = lib.mkEnableOption "hardware utilities" // {
      # TODO: detect headless physical machine
      default = config.hardware.graphics.enable;
    };
  };

  config = lib.mkIf cfg.enable {

    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set -U fish_greeting
      '';
    };

    programs.yazi.enable = true;

    environment.systemPackages =
      with pkgs;
      (
        [
          fastfetch

          tree
          gdu
          just
          yq
          jq
          rclone
          dos2unix
          tlrc
          ripgrep
          fd
          _7zz

          nodejs # npm will NOT install this
          python3
          gcc

          age
          sops
        ]
        ++ lib.optionals cfg.enableHardwareUtils [
          exfatprogs
          e2fsprogs
          usbutils
          pciutils
          lm_sensors
        ]
      );

    # may migrate to pnpm
    programs.npm = {
      enable = true;
      npmrc = ''
        prefix=''${XDG_DATA_HOME}/npm
        cache=''${XDG_CACHE_HOME}/npm
        init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
        tmp=''${XDG_RUNTIME_DIR}/npm
      '';
    };
  };
}
