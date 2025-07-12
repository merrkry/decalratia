{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.profiles.base.secrets;
in
{
  options.profiles.base.secrets = {
    enable = lib.mkEnableOption "secrets" // {
      default = config.profiles.base.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.keyFile = "/var/lib/sops-nix/key.txt";
      defaultSopsFile = "${inputs.secrets}/${config.networking.hostName}/secrets.yaml";
    };
  };
}
