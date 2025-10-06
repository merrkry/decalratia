{
  config,
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
        package = pkgs.zed-editor;
      };

      # stylix.targets.zed.enable = true;
    };
  };
}
