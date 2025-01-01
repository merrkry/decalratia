{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    deploy-rs
    nh
  ];
  shellHook = ''
    fish
  '';
}
