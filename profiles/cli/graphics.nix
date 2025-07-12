{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.graphics;
in
{
  options.profiles.cli.graphics = {
    enable = lib.mkEnableOption "graphics";
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      home.packages = with pkgs; [
        xorg.xeyes
        glxinfo
        vulkan-tools
      ];

    };

  };
}
