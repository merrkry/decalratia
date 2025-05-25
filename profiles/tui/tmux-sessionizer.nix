{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.tmux-sessionizer;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.tui.tmux-sessionizer = {
    enable = lib.mkEnableOption' { };
    enableFishIntegration = lib.mkEnableOption "Fish integration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.users.${user} = {
          home.packages = [ pkgs.tmux-sessionizer ];

          xdg.configFile."tms/config.toml".source = pkgs.writers.writeTOML "config.toml" {
            display_full_path = true;
            session_sort_order = "LastAttached";

            picker_colors = {
              highlight_color = "#393939";
              highlight_text_color = "#DEE0E0";
            };

            search_dirs = [
              {
                path = "${hmConfig.home.homeDirectory}/Projects";
                depth = 4;
              }
            ];
          };
        };
      }
      (lib.mkIf cfg.enableFishIntegration {
        home-manager.users.${user} = {
          programs.fish.interactiveShellInit = ''
            bind \cf ${lib.getExe pkgs.tmux-sessionizer}
          '';
        };
      })
    ]
  );
}
