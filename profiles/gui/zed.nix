{
  config,
  helpers,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.gui.zed;
in
{
  options.profiles.gui.zed = {
    enable = lib.mkEnableOption "zed";
    enableAI = lib.mkEnableOption "AI";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.zed-editor = {
        enable = true;
        # Running in fhs might let LSP unable to find system libraries,
        # e.g. pkg-config, openssl provided by nix shell.
        # Providing them fhsWithPackages doesn't work either.
        # Better to use with nix-ld.
        package = helpers.overrideRustPlatformArgs pkgs "zed-editor" (finalAttrs: {
          version = "1.1.2-pre";
          src = pkgs.fetchFromGitHub {
            owner = "zed-industries";
            repo = "zed";
            tag = "v${finalAttrs.version}";
            hash = "sha256-C6/YS69pAO6qurDOWcEDeuJ4+jVZsUnEQ7+fHUxlurE=";
          };
          cargoHash = "sha256-RgSFeCNDg5pD1rYBf2A9iZ5RB78QHHZfE0xTgiA1008=";
        });
      };
    };
  };
}
