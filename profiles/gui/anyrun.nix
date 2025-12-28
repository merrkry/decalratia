{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.anyrun;
  hmConfig = config.home-manager.users.${user};
  pkg = hmConfig.programs.anyrun.package;
in
{
  options.profiles.gui.anyrun = {
    enable = lib.mkEnableOption "anyrun";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.anyrun = {
        enable = true;
        config = {
          x.fraction = 0.5;
          y.fraction = 0.3;
          width.fraction = 0.4;
          height.absolute = 1;

          hidePluginInfo = true;
          closeOnClick = true;

          plugins =
            let
              mkBuiltinPluginList = lib.map (name: "${pkg}/lib/lib${name}.so");
            in
            mkBuiltinPluginList [
              "applications"
              "symbols"
            ];
        };

        extraConfigFiles = {
          "stdin.ron".text =
            # ron
            ''
              Config(
                allow_invalid: false,
                // Value passed by CLI args cannot exceed this value.
                max_entries: 16,
                preserve_order: false,
              )
            '';
        };

        extraCss = null; # WIP, managed by chezmoi
      };

      # https://github.com/anyrun-org/anyrun/blob/cacdf2e00cf95211bd2c7971c4037b21870bc2c9/nix/modules/home-manager.nix#L395
      systemd.user.services.anyrun = {
        Unit = {
          Description = "Anyrun daemon";
          PartOf = "graphical-session.target";
          After = "graphical-session.target";
        };

        Service = {
          Type = "simple";
          ExecStart = "${lib.getExe pkg} daemon";
          Restart = "on-failure";
          KillMode = "process";
        };

        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
