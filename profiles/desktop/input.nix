{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.profiles.desktop.input;
in
{
  imports = [ inputs.xremap.nixosModules.default ];

  options.profiles.desktop.input = {
    enable = lib.mkEnableOption' { default = config.profiles.desktop.enable; };
  };

  config = lib.mkMerge [
    {
      # xremap is enabled by default, leaving an empty config that causes eval fail when cfg.enable is false
      services.xremap.enable = lib.mkDefault false;
    }
    (lib.mkIf cfg.enable {
      services.xremap = {
        enable = true;
        config.modmap = [
          {
            name = "Global";
            remap = {
              "CapsLock" = "Esc";
              "Esc" = "CapsLock";
            };
          }
        ];
      };
    })

  ];
}
