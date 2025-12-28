{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.rofi;
  hmConfig = config.home-manager.users.${user};
in
{
  options.profiles.gui.rofi = {
    enable = lib.mkEnableOption "rofi";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.rofi = {
        enable = true;
        package = pkgs.rofi.override {
          rofi-unwrapped = pkgs.rofi-unwrapped.overrideAttrs (
            final: prev: {
              src = pkgs.fetchFromGitHub {
                owner = "davatorium";
                repo = "rofi";
                rev = "c1f9b160c535333feba570d832e1157ebdf4c24c";
                fetchSubmodules = true;
                hash = "sha256-+8QB0zW8Cc2I31uV20uBjrZC4afsTZ5MYeBx5b/qiRU=";
              };
            }
          );
        };
        terminal = config.profiles.desktop.defaultTerminal;
      };

      stylix.targets.rofi.enable = true;
    };
  };
}
