# Configs not managed by Nix

## chezmoi

Configs barely documented or frequently edited by software are now managed by chezmoi.

## jetbrains IDEs

I gave up manage jetbrains software with Nix by any means. As they

- are extremely slow to download, drastically slow down builds and waste binary cache's resource
- create another layer of complexity on already magical proprietary software

With their official toolbox, I can do incremental updates, or lock to whatever version I want.

Note that `nix-ld` is also required in addition to installing these packages.

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
