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
            remap = {
              "CAPSLOCK" = {
                held = "LEFTCTRL";
                alone = "ESC";
                free_hold = true;
              };
              "ESC" = "CAPSLOCK";
            };
          }
        ];
      };
    };
  };
}
