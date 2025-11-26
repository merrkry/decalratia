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
    enable = lib.mkEnableOption "input" // {
      default = config.profiles.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services.xremap = {
      enable = true;
      configFile = pkgs.writers.writeYAML "config.yaml" {
        modmap = [
          {
            name = "Useful CapsLock";
            device.only = [
              "AT Translated Set 2 keyboard" # ThinkPad E14 Gen 3
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
