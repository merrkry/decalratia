pkgs: {
  apple-color-emoji = pkgs.callPackage ./apple-color-emoji.nix { };
  apple-system-fonts = pkgs.callPackage ./apple-system-fonts.nix { };
  bookerly = pkgs.callPackage ./bookerly.nix { };
  deeplx = pkgs.callPackage ./deeplx.nix { };
  kvlibadwaita-kvantum = pkgs.callPackage ./kvlibadwaita-kvantum.nix { };
  dream-han-cjk-sans = pkgs.callPackage ./dream-han-cjk-sans.nix { };
  dream-han-cjk-serif = pkgs.callPackage ./dream-han-cjk-serif.nix { };
  xremap = pkgs.callPackage ./xremap.nix { };
}
