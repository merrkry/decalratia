{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    distrobox
    materialgram
    (obsidian.override { commandLineArgs = lib.chromiumArgs; })
    xournalpp
  ];
}
