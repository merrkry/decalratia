{ inputs, lib, ... }:
let
  secretHelpers = import inputs.secrets { inherit lib; };
in
{
  inherit (secretHelpers) sshKeys;

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

  chromiumArgs = [
    "--ozone-platform-hint=auto"
    "--enable-features=WaylandWindowDecorations"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
  ];

  recommendedBtrfsArgs = [
    "noatime"
    "compress-force=zstd:1"
  ];

  servicePorts = {
    atuin = 20001;
    atticd = 20002;
    kanidm = 20003;
    open-webui = 20004;
    vaultwarden = 20005;
    memos = 20006;
    miniflux = 20007;
    matrix-synapse = 20008;
    dufs = 20009;
    sillytavern = 20010;
    couchdb = 20011;

    mautrix-telegram = 29317; # This should match the app service registration file, which is in secrets
  };
}
