{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    deploy-rs
    nixd
    nixfmt-rfc-style
    nh
  ];
}
