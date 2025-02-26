{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    distrobox
    jetbrains.idea-ultimate
    materialgram
    (obsidian.override { commandLineArgs = lib.chromiumArgs; })
    xournalpp
  ];
}
