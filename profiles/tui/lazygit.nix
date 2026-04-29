{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.lazygit;
in
{
  options.profiles.tui.lazygit = {
    enable = lib.mkEnableOption "lazygit";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.lazygit = {
        enable = true;
        settings = {
          git = {
            autoFetch = false;
            log = {
              order = "default";
            };
            pagers = [
              {
                externalDiffCommand = "${lib.getExe pkgs.difftastic} --color=always --display=inline";
              }
            ];
          };
          gui = {
            nerdFontsVersion = 3;
          };
          update.method = "never";
        };
      };
    };
  };
}
