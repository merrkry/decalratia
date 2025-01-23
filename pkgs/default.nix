pkgs: {
  bookerly = pkgs.callPackage ./bookerly.nix { };
  deeplx = pkgs.callPackage ./deeplx { };
  kvlibadwaita-kvantum = pkgs.callPackage ./kvlibadwaita-kvantum.nix { };
  memogram = pkgs.callPackage ./memogram.nix { };
  noto-fonts-cjk-sans-static = pkgs.callPackage ./noto-fonts-cjk-sans-static.nix { };
  noto-fonts-cjk-serif-static = pkgs.callPackage ./noto-fonts-cjk-serif-static.nix { };
}
