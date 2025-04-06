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
        package = pkgs.ungoogled-chromium.override { enableWideVine = true; };
        commandLineArgs = lib.chromiumArgs ++ [
          "--password-store=gnome-libsecret"
          "--enable-features=AcceleratedVideoDecodeLinuxGL"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
        # doesn't work for ungoogled-chromium, https://github.com/nix-community/home-manager/pull/4174
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
