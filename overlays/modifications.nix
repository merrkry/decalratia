{ pkgs, ... }:
{
  # Allow to keep the same name between updates
  # https://github.com/chaotic-cx/nyx/blob/main/pkgs/proton-ge-custom/default.nix
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/pr/proton-ge-bin/package.nix
  proton-ge-bin = pkgs.proton-ge-bin.overrideAttrs (
    finalAttrs: oldAttrs: {
      # fetchzip handles unpacking on its own, instead of unpackPhase
      # might be better to use fetchurl and extract in buildCommand to reduce i/o consumption
      # but will hash change?
      buildCommand = ''
        # Make it impossible to add to an environment. You should use the appropriate NixOS option.
        # Also leave some breadcrumbs in the file.
        echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

        cp -r $src/ $steamcompattool
        substituteInPlace $steamcompattool/compatibilitytool.vdf --replace-fail "${oldAttrs.version}" "Proton-GE"
      '';
    }
  );

  xwayland-satellite = pkgs.callPackage pkgs.xwayland-satellite.override {
    rustPlatform = pkgs.rustPlatform // {
      buildRustPackage =
        args:
        pkgs.rustPlatform.buildRustPackage (
          args
          // {
            src = pkgs.fetchFromGitHub {
              owner = "Supreeeme";
              repo = "xwayland-satellite";
              rev = "56a681bfecc5831f41f8eb0ec8c7e96c6b277153";
              hash = "sha256-Tdsw5lD/XM8i1GnQr7ombqnEaCpt/voPs2AbjuYBbjI=";
            };
            cargoLock = null;
            useFetchCargoVendor = true;
            cargoHash = "sha256-QsU960aRU+ErU7vwoNyuOf2YmKjEWW3yCnQoikLaYeA";
          }
        );
    };
  };
}
