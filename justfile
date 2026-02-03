cleanup:
  rm -rf ~/.cache/nix
  sudo rm -rf /root/.cache/nix

sync:
  git pull --autostash

update: chezmoi flatpak rime rustup

[group('update')]
chezmoi:
  chezmoi apply --interactive --source ./chezmoi

[group('update')]
flatpak:
  flatpak --user update --noninteractive

[group('update')]
rime:
  busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 \
    SetConfig sv fcitx://config/addon/rime/deploy s ''

  yq --yaml-output --in-place \
    '.var.option.ascii_punct = false | \
     .var.option.emoji = false | \
     .var.option.full_shape = false | \
     .var.option.simplification = true | \
     .var.option.traditionalization = false | \
     .var.previously_selected_schema = "double_pinyin_fly"' \
    ~/.local/share/fcitx5/rime/user.yaml

[group('update')]
rustup:
  rustup update nightly
  rustup component add --toolchain nightly rust-analyzer
  rustup component add --toolchain nightly rustc-codegen-cranelift-preview
  rustup default nightly
