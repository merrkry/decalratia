{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      anki
      distrobox
      imagemagick
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
      "app.zen_browser.zen"
      "com.discordapp.Discord"
      "com.qq.QQ"
      "com.spotify.Client"
      "com.usebottles.bottles"
      "md.obsidian.Obsidian"
    ];
  };
}
