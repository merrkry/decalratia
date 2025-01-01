{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [ deploy-rs ];
  shellHook = ''
    fish
  '';
}
