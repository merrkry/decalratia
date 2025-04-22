{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.desktop.input;
in
{
  options.profiles.desktop.input = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkIf cfg.enable {
    services.xremap = {
      enable = true;
      configFile = pkgs.writeText "config.yaml" ''
        modmap:
        - name: Global
          remap:
            CapsLock: Esc
            Esc: CapsLock
      '';
    };
  };
}
