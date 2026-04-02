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

  basePackage = pkgs.ungoogled-chromium.override {
    commandLineArgs = helpers.chromiumArgs ++ [
      "--password-store=gnome-libsecret"
      "--enable-features=AcceleratedVideoDecodeLinuxGL"
    ];
    enableWideVine = true;
  };

  # Workaround for a bug in timezone handling.
  # Similar to legacy issue https://issues.chromium.org/issues/40540835,
  # instead of reading /etc/localtime, Chromium falls back to ICU etc. for timezone information,
  # which returns `CST` in `Asia/Shanghai`, which can also be parsed as "Central Standard Time",
  # causing timezone to be set as `America/Chicago` inside chromium sandbox.
  # We set `TZ` manually on chromium launch to avoid such behavior.
  package = pkgs.symlinkJoin {
    name = "chromium";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/chromium \
        --run 'export TZ=$(${pkgs.systemd}/bin/timedatectl show --property=Timezone --value)'

      rm $out/bin/chromium-browser
      ln -s $out/bin/chromium $out/bin/chromium-browser
    '';
    inherit (basePackage) meta;
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
