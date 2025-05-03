{ pkgs, ... }:
{
  home.packages = with pkgs; [
    distrobox
    materialgram
    xournalpp
  ];

  services.flatpak.packages = [ "md.obsidian.Obsidian" ];
}
