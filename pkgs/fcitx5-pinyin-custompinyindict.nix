{
  stdenv,
  lib,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "fcitx5-pinyin-custompinyindict";
  version = "20240621";

  src = fetchurl {
    url = "https://github.com/wuhgit/CustomPinyinDictionary/releases/download/assets/CustomPinyinDictionary_Fcitx_20240824.tar.gz";
    hash = "sha256-5juOsS4hyUt7MlXmR1UKhOKX55j1KTlp8mFvkZDdGRQ=";
  };

  unpackPhase = ''
    runHook preUnpack
    tar -xvf $src
  '';

  installPhase = ''
    install -Dm644 CustomPinyinDictionary_Fcitx.dict $out/share/fcitx5/pinyin/dictionaries/CustomPinyinDictionary_Fcitx.dict
  '';

  meta = with lib; {
    description = "自建拼音输入法词库，百万常用词汇量，适配 Fcitx5 (Linux / Android) 及 Gboard (Android + Magisk) 。";
    homepage = "https://github.com/wuhgit/CustomPinyinDictionary";
    license = licenses.unlicense;
  };
}
