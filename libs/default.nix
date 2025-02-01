{ lib, ... }:
{
  mkModulesList =
    path:
    (lib.pipe path [
      builtins.readDir
      (lib.mapAttrsToList (
        name: value:
        (
          if
            (
              value == "regular"
              && lib.hasSuffix ".nix" name
              && !(builtins.elem name [
                "default.nix"
                "home.nix"
              ])
            )
            || (value == "directory")
          then
            name
          else
            null
        )
      ))
      (lib.filter (x: x != null))
      (lib.map (fileName: path + "/${fileName}"))
    ]);

  mkEnableOption' =
    {
      default ? false,
    }:
    lib.mkOption {
      inherit default;
      type = lib.types.bool;
      visible = false;
    };

  chromiumArgs = [
    "--ozone-platform-hint=auto"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
  ];

  sshKeys =
    let
      akahi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFvfIUnhsW4vVl/SKxT3Nf1WG4YEVbrM9IlmB4GDp/t merrkry@akahi";
      cryolite = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+3CQaKRYPGk6yLS6eXhmZk6igB8itkTbkvgfQUvJPW merrkry@cryolite";
      karanohako = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIAg9BDaX6NeZmA3ux+Zr5Dd6zhBCu4Ohs0iORgojXN4 merrkry@karanohako";
    in
    {
      trusted = [
        akahi
        cryolite
        karanohako
      ];
    };
}
