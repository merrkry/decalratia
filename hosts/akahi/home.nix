{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      anki
      distrobox
      gparted
      imagemagick
      kdePackages.kdenlive
      materialgram
      nali
      numbat
      podman-compose
      (prismlauncher.override { jdks = [ jdk17 ]; })
      q
      tsukimi
      xournalpp
    ];
  };

  services = {
    flatpak.packages = [
      "com.discordapp.Discord"
      "com.qq.QQ"
      "com.spotify.Client"
      "com.usebottles.bottles"
      "com.valvesoftware.Steam"
      "md.obsidian.Obsidian"
      "runtime/org.freedesktop.Platform.VulkanLayer.gamescope/x86_64/24.08" # need to match the version that steam is built on
      "runtime/com.valvesoftware.Steam.CompatibilityTool.Proton-GE/x86_64/stable"
    ];
  };
}
