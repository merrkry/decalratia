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
    enable = lib.mkEnableOption "input";
  };

  config = lib.mkIf cfg.enable {
    services.xremap = {
      enable = true;
      configFile = pkgs.writers.writeYAML "config.yaml" {
        modmap = [
          {
            name = "Useful CapsLock";
            device.only = [
              "AT Translated Set 2 keyboard" # cryolite, osmium
              "Milsky 87EC-XRGB"
            ];
            remap = {
              "CAPSLOCK" = "ESC";
              "ESC" = "CAPSLOCK";
            };
          }
        ];
      };
    };
  };
}
