{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      environment.sessionVariables = {
        __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
        VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/intel_icd.x86_64.json";
        __GLX_VENDOR_LIBRARY_NAME = "mesa";

        # Intel GPU Vulkan decode, see https://github.com/mpv-player/mpv/discussions/13909
        ANV_VIDEO_DECODE = "1";
      };

      programs.gamescope.enable = true;
    }
    (lib.mkIf (config.specialisation != { }) {
      boot.extraModprobeConfig = ''
        options nvidia NVreg_UsePageAttributeTable=1 NVreg_InitializeSystemMemoryAllocations=0
      '';

      environment.systemPackages = [
        # __NV_PRIME_RENDER_OFFLOAD_PROVIDER may be useful for multi-screen
        # https://download.nvidia.com/XFree86/Linux-x86_64/435.17/README/primerenderoffload.html
        (pkgs.writeShellScriptBin "prime-run" ''
          export __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json
          export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
          export __NV_PRIME_RENDER_OFFLOAD=1
          export __GLX_VENDOR_LIBRARY_NAME=nvidia
          export __VK_LAYER_NV_optimus=NVIDIA_only
          exec "$@"
        '')
      ];

      hardware = {
        nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = true;
          open = true;
          nvidiaSettings = false;
          nvidiaPersistenced = true;
          dynamicBoost.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.production;
          prime = {
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
            offload.enable = true;
          };
        };
        nvidia-container-toolkit.enable = true;
      };

      services.xserver.videoDrivers = [ "nvidia" ];
    })
  ];
}
