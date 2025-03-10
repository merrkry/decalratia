{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.chromium;
in
{
  options.profiles.gui.chromium = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.chromium = {
        enable = true;
        # https://github.com/ungoogled-software/ungoogled-chromium/issues/3226
        package = pkgs.chromium.override { enableWideVine = true; };
        commandLineArgs = lib.chromiumArgs ++ [
          "--password-store=gnome-libsecret"
          "--enable-features=AcceleratedVideoDecodeLinuxGL"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
        # doesn't work for ungoogled-chromium
        # extensions = [
        #   {
        #     id = "ocaahdebbfolfmndjeplogmgcagdmblk";
        #     updateUrl = "https://raw.githubusercontent.com/NeverDecaf/chromium-web-store/refs/heads/master/updates.xml";
        #   }
        # ];
      };

    };

  };
}
