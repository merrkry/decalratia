pkgs: {
  bookerly = pkgs.callPackage ./bookerly.nix { };
  fcitx5-pinyin-custompinyindict = pkgs.callPackage ./fcitx5-pinyin-custompinyindict.nix { };
  memogram = pkgs.callPackage ./memogram.nix { };
  noto-fonts-cjk-sans-static = pkgs.callPackage ./noto-fonts-cjk-sans-static.nix { };
  noto-fonts-cjk-serif-static = pkgs.callPackage ./noto-fonts-cjk-serif-static.nix { };
}
