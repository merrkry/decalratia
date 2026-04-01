# Memory leak as of v1.3.1: closing windows does not return memory.
{
  config,
  lib,
  user,
  ...
}:
let
  cfg = config.profiles.gui.ghostty;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.gui.ghostty = {
    enable = lib.mkEnableOption "ghostty";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home-manager.users.${user} = {
        assertions = [
          {
            assertion = hmConfig.programs.ghostty.settings == { };
            message = "Config managed by Chezmoi";
          }
        ];

        programs.ghostty.enable = true;
      };
    })
    {
      home-manager.users.${user} = {
        # The module creates unit files via symlink instead of module options,
        # we need to enable it manually.
        systemd.user.tmpfiles.rules =
          let
            serviceName = "app-com.mitchellh.ghostty.service";
            linkPath = "%h/.config/systemd/user/default.target.wants/${serviceName}";
            targetPath = "%h/.config/systemd/user/${serviceName}";
          in
          if cfg.enable then
            [
              "L+ ${linkPath} - - - - ${targetPath}"
            ]
          else
            [
              "r ${linkPath}"
            ];
      };
    }
  ];
}
