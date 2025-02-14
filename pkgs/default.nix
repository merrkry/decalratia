pkgs: {
  apple-color-emoji = pkgs.callPackage ./apple-color-emoji.nix { };
  apple-system-fonts = pkgs.callPackage ./apple-system-fonts.nix { };
  bookerly = pkgs.callPackage ./bookerly.nix { };
  deeplx = pkgs.callPackage ./deeplx.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./kvlibadwaita-kvantum.nix { };
  noto-fonts-cjk-sans-static = pkgs.callPackage ./noto-fonts-cjk-sans-static.nix { };
  noto-fonts-cjk-serif-static = pkgs.callPackage ./noto-fonts-cjk-serif-static.nix { };
}
