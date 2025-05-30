{ pkgs, ... }:
{
  xwayland-satellite = pkgs.callPackage pkgs.xwayland-satellite.override {
    rustPlatform = pkgs.rustPlatform // {
      buildRustPackage =
        args:
        pkgs.rustPlatform.buildRustPackage (
          args
          // rec {
            version = "0.6";
            src = pkgs.fetchFromGitHub {
              owner = "Supreeeme";
              repo = "xwayland-satellite";
              tag = "v${version}";
              hash = "sha256-IiLr1alzKFIy5tGGpDlabQbe6LV1c9ABvkH6T5WmyRI=";
            };
            cargoLock = null;
            useFetchCargoVendor = true;
            cargoHash = "sha256-R3xXyXpHQw/Vh5Y4vFUl7n7jwBEEqwUCIZGAf9+SY1M=";
          }
        );
    };
  };
}
