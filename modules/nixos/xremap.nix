{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.xremap;
in
{
  options.services.xremap = {
    enable = lib.mkEnableOption "xremap";
    configFile = lib.mkOption {
      type = lib.types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."xremap" = {
      # TODO: more fine-grained privilege control, ref to https://github.com/xremap/nix-flake/blob/master/modules/system-service.nix
      # or consider migrate to user service
      serviceConfig = {
        Type = "exec";
        ExecStart = "${lib.getExe pkgs.xremap} ${cfg.configFile} --watch=device";
        Nice = -20;
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
