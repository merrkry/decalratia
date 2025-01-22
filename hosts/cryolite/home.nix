{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
    materialgram
    (obsidian.override { commandLineArgs = lib.ChromiumArgs; })
    xournalpp
  ];
}
