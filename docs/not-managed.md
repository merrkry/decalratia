# Configs not managed by Nix

## fcitx5

Current module only provides an INI converter (`i18n.inputMethod.fcitx5.settings.globalOptions`).

Currently copies `~/.config/fcitx5/` manually.

## jetbrains IDEs

`nix-ld` is also required in addition to installing `jetbrains.idea-ultimate`

```
-Xmx4G

# wayland support
-Dawt.toolkit.name=WLToolkit

# follow xdg standards
-Djdk.downloader.home=/home/merrkry/.local/share/jdks

# required by google-java-format
--add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED
--add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED
--add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED
--add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED
--add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED
--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
```
