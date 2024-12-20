{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  stylix.targets = {
    vscode.enable = false;
    kde.enable = false;
  };

  # TODO: migrate to profiles
  # https://discourse.nixos.org/t/guide-to-installing-qt-theme/35523/3
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum"; # "adwaita-dark";
    # style.package = pkgs.adwaita-qt;
  };
  # FIXME: impure: relies on manual install https://github.com/GabePoel/KvLibadwaita
  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=KvLibadwaitaDark
    '';
  };
}
