{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.profiles.tui.neovim;
  hmConfig = config.home-manager.users.${user};
  basePackage = pkgs.neovim; # inputs.neovim-nightly-overlay.packages.${config.nixpkgs.system}.default;
  extraBins = with pkgs; [
    # tree-sitter # might be outdated, migrated to mason.
    unzipNLS # stylua
  ];
  extraLibs = with pkgs; [
    sqlite # snacks.nvim
  ];
  wrappedPackage = pkgs.symlinkJoin {
    name = "neovim-extended";
    paths = [ basePackage ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${lib.makeBinPath extraBins} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath extraLibs}
    '';
  };
in
{
  options.profiles.tui.neovim = {
    enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${user} = {
      home.packages = [ wrappedPackage ];

      systemd.user.tmpfiles.rules = [
        "L+ ${hmConfig.xdg.configHome}/nvim - - - - ${hmConfig.home.homeDirectory}/Projects/declaratia/nvim"
      ];
    };
  };
}
