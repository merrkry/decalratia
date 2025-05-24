{ pkgs, ... }:
{
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
              rev = "572fa4a2bfe920daacdefc7e564b49115413306a";
              hash = "sha256-t9XPqehcZYDh4YVDq6w/c/L+MhoE/9MIQSYTQOwMwp8=";
            };
            cargoLock = null;
            useFetchCargoVendor = true;
            cargoHash = "sha256-QsU960aRU+ErU7vwoNyuOf2YmKjEWW3yCnQoikLaYeA";
          }
        );
    };
  };
}
