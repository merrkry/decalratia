{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    distrobox
    fractal
    jetbrains.idea-ultimate
    materialgram
    (obsidian.override { commandLineArgs = lib.chromiumArgs; })
    xournalpp
  ];
}
