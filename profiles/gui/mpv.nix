{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.mpv;
in
{
  options.profiles.gui.mpv = {
    enable = lib.mkEnableOption' { };
  };

  config = lib.mkIf cfg.enable {

    home-manager.users.${user} = {

      programs.mpv = {
        enable = true;

        scripts = with pkgs.mpvScripts; [
          thumbfast
          modernx
        ];

        config = {
          profile = "high-quality";
          vo = "gpu-next";
          gpu-api = "vulkan";
          # vulkan hwdec is buggy
          # Adding aufo-safe will sometimes wakeup Nvidia dGPU
          hwdec = "vaapi";
          gpu-context = "waylandvk";

          deband = "yes";
          icc-profile-auto = "yes";

          blend-subtitles = "video";

          video-sync = "display-resample";
          interpolation = "yes";
          tscale = "oversample";

          sub-auto = "fuzzy";

          keep-open = "yes";
          save-position-on-quit = "yes";

          osc = "no";
          # border = "no";
        };
      };

    };

  };
}
