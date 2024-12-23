{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.cli.helix;
in
{
  options.profiles.cli.helix = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.helix = {
        enable = true;
        languages.language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "${lib.getExe pkgs.nixfmt-rfc-style} --strict";
          }
        ];
      };

    };

  };

}
