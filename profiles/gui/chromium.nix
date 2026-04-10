{
  config,
  helpers,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.chromium;

  package = pkgs.ungoogled-chromium.override {
    commandLineArgs = helpers.chromiumArgs ++ [
      "--password-store=gnome-libsecret"
      "--enable-features=AcceleratedVideoDecodeLinuxGL"
    ];
    enableWideVine = true;
  };
in
{
  options.profiles.gui.chromium = {
    enable = lib.mkEnableOption "chromium";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      # Home-manager's module is designed for managing extensions etc.,
      # but doesn't seem to work for ungoogled-chromium so there is no need to use it.
      # Also note that the module adds extra overrides, so we should wrap around
      # `programs.chromium.finalPackage` instead of `programs.chromium.package`.
      home.packages = [ package ];
    };
  };
}
